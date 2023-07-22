extends Node
class_name Serializer

const debug_logs = false


# Find recursivly every wanted nodes, and extract their wanted properties
static func fetch_branch_state(property_dict: Dictionary, root_node: Node, ignored_classes := PoolStringArray(),
								 dict_to_fill : Dictionary = {}, node: Node = null, return_at_first_found : bool = false) -> Dictionary:
	
	var class_array = property_dict.keys()
	
	if node == null: 
		node = root_node
	
	# Check for direct children to find a matching class
	for child in node.get_children():
		var matched_class = Utils.match_classv(child, class_array)
		
		if matched_class != "":
			var object_properties = get_object_properties(property_dict[matched_class], child)
			
			dict_to_fill[root_node.get_path_to(child)] = object_properties
			if return_at_first_found:
				return dict_to_fill
	
	# Check for indirect children to find a matching class
	for child in node.get_children():
		for _class in ignored_classes:
			if child.is_class(_class):
				return dict_to_fill
		
		var __ = fetch_branch_state(property_dict, root_node, ignored_classes, dict_to_fill, child)

	return dict_to_fill



static func fetch_groupped_nodes_state(group_array: Array, scene_root: Node, property_dict: Dictionary, ignored_classes := PoolStringArray()) -> Dictionary:
	var dict = {}
	
	for group in group_array:
		var nodes_array = scene_root.get_tree().get_nodes_in_group(group)
		var class_array = property_dict.keys()
		
		for node in nodes_array:
			if Utils.match_classv(node, ignored_classes) != "":
				continue
			
			var matched_class = Utils.match_classv(node, class_array)
			
			if matched_class != "":
				var object_properties = get_object_properties(property_dict[matched_class], node)
				dict[scene_root.get_path_to(node)] = object_properties
				
				continue
			
			dict = fetch_branch_state(
				property_dict, 
				scene_root, 
				ignored_classes,
				dict,
				node,
				true
			)
	
	return dict



# Recursivly get every persistant objects direct/indirect children of the given node
# Store the data in the array passed as argument
static func get_every_persistant_object(node: Node, persistants_classes := PoolStringArray(), array_to_fill: Array = []) -> Array:
	for child in node.get_children():
		for _class in persistants_classes:
			if child.is_class(_class) or child.is_in_group(_class):
				if not child in array_to_fill:
					array_to_fill.append(child)
		
			elif child.get_child_count() > 0:
				array_to_fill = get_every_persistant_object(child, persistants_classes, array_to_fill)
		
	return array_to_fill


# Fetch the given properties of the given object and returns it as a Dictionary
# Where each pair represent a property name as a key and the propery value as a value
static func serialize_state(obj: Object, properties : PoolStringArray) -> Dictionary:
	var state = {}
	
	if !is_instance_valid(obj):
		push_error("The given object isn't a valid instance, cannot fetch any state from it")
		return {}
	
	for property in properties:
		if property in obj:
			state[property] = obj.get(property)
		else:
			push_error("Property %s not found in node %s" % [property, str(obj)])
	
	return state


static func serialize_whole_state(obj: Object, recursive: bool = false) -> Dictionary:
	var properties = ClassDB.class_get_property_list(obj.get_class(), recursive)
	return serialize_state(obj, PoolStringArray(properties))


static func apply_state(obj: Object, state: Dictionary) -> void:
	if !is_instance_valid(obj):
		push_error("The given object isn't a valid instance, cannot apply any state to it")
		return
	
	for property in state.keys():
		if property in obj:
			 obj.set(property, state[property])
		else:
			push_error("Property %s not found in obj %s" % [property, str(obj)])


# Apply a state to the given branch
# The state_dict must be structured this way:
# Keys are the path to the node, relative to the branch_root, then the value is another dict where keys
# are the name of the property and the value its value
static func branch_apply_state(branch_root: Node, groups_array: Array, state_dict : Dictionary, peristant_classes: Array = []) -> void:
	var state_paths_array = state_dict.keys()
	
	for group in groups_array:
		var nodes_array = branch_root.get_tree().get_nodes_in_group(group)
		
		for node in nodes_array:
			if node == null or node.is_queued_for_deletion():
				continue
			
			var node_path = branch_root.get_path_to(node)
			
			if Utils.match_classv(node, peristant_classes) != "":
				continue
			
			# Found node to apply state to 
			if node_path in state_paths_array:
				for property in state_dict[node_path].keys():
					if property == "name":
						continue
					
					var value = state_dict[node_path][property]
					var setter = "set_" + property
					if node.has_method(setter):
						node.call(setter, value)
					else:
						node.set(property, value)
					
					if debug_logs: print("Node ", node.name, ", property: ", property, " set to: ", value)
			
			# Found node to destroy 
			elif Utils.match_classv(node, SaveData.level_property_to_serialize.keys()) != "":
				
				if debug_logs: print("Node ", node.name, " freed")
				node.queue_free()


static func is_node_state_ignored(node: Node, state_classes_ignored := PoolStringArray()) -> bool:
	for class_ignored in state_classes_ignored:
		if node.is_class(class_ignored) or (node.owner && node.owner.is_class(class_ignored)):
			return true
	return false


# Take an object, find every properties needed in it and retrun the data as a dict
static func get_object_properties(properties: Array, object : Object) -> Dictionary:
	var property_data_dict : Dictionary = {}
	property_data_dict['name'] = object.get_name()
	
	for property in properties:
		if property in object:
			property_data_dict[property] = object.get(property)
		
		elif object.has_method("get_" + property):
			property_data_dict[property] = object.call("get_" + property)
		
		else:
			push_error("Property : " + property + " could not be found in " + object.name)
	
	return property_data_dict
