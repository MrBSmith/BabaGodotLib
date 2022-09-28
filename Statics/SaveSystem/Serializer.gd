extends Node
class_name Serializer


# Find recursivly every wanted nodes, and extract their wanted properties
static func fetch_branch_state(property_dict: Dictionary, root_node: Node, ignored_classes := PoolStringArray(),
								 dict_to_fill : Dictionary = {}, node: Node = null) -> Dictionary:
	
	var class_path_array = property_dict.keys()
	if node == null: 
		node = root_node
	
	for class_path in class_path_array:
		var found_nodes_array = Utils.fetch_from_class_path(node, class_path, ignored_classes)
		
		for found_node in found_nodes_array:
			var object_properties = get_object_properties(property_dict, found_node)
			
			dict_to_fill[root_node.get_path_to(found_node)] = object_properties
	
	for child in node.get_children():
		for _class in ignored_classes:
			if child.is_class(_class):
				return dict_to_fill
		
		var __ = fetch_branch_state(property_dict, root_node, ignored_classes, dict_to_fill, child)
	
	return dict_to_fill


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


# Apply a state to the given branch
# The state_dict must be structured this way:
# Keys are the path to the node, relative to the branch_root, then the value is another dict where keys
# are the name of the property and the value its value
static func branch_apply_state(branch_root: Node, state_dict : Dictionary, persistant_classes := PoolStringArray(), ignored_classes := PoolStringArray()) -> void:
	var persitiant_objects : Array = []
	var undestructed_obj : Array = []

	for object_path in state_dict.keys():
		var object = branch_root.get_node_or_null(object_path)
		
		if object == null:
			var path_as_string = String(object_path).replace("@", "")
			object = branch_root.get_node_or_null(path_as_string)
			
			if object == null:
				push_warning("The object with path : " + object_path + " couldn't be found")
				continue
		
		if is_node_state_ignored(object, ignored_classes):
			continue
		
		if not object in undestructed_obj:
			undestructed_obj.append(object)

		for property in state_dict[object_path].keys():
			var value = state_dict[object_path][property]
			var setter = "set_" + property
			if object.has_method(setter):
				object.call(setter, value)
			else:
				object.set(property, value)
	
	if !branch_root.is_inside_tree():
		yield(branch_root, "ready")
	
	persitiant_objects = get_every_persistant_object(branch_root, persistant_classes)
	
	for obj in persitiant_objects:
		if not obj in undestructed_obj:
			obj.queue_free()


static func is_node_state_ignored(node: Node, state_classes_ignored := PoolStringArray()) -> bool:
	for class_ignored in state_classes_ignored:
		if node.is_class(class_ignored) or (node.owner && node.owner.is_class(class_ignored)):
			return true
	return false


# Take an object, find every properties needed in it and retrun the data as a dict
static func get_object_properties(property_dict: Dictionary, object : Object) -> Dictionary:
	
	var class_path = ""
	
	for path in property_dict.keys():
		var _class = path.split("/")[-1]
		if object.is_class(_class):
			class_path = path
			break
	
	var property_list : Array = property_dict[class_path]
	var property_data_dict : Dictionary = {}
	property_data_dict['name'] = object.get_name()
	
	for property in property_list:
		if property in object:
			property_data_dict[property] = object.get(property)
		elif object.has_method("get_" + property):
			property_data_dict[property] = object.call("get_" + property)
		else:
			push_error("Property : " + property + " could not be found in " + object.name)

	return property_data_dict

