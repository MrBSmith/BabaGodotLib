extends Node
class_name LevelSaver


# Find recursivly every wanted nodes, and extract their wanted properties
static func serialize_level_properties(property_dict: Dictionary, node : Node, dict_to_fill : Dictionary):
	var classes_to_scan_array = property_dict.keys()
	for node_class in classes_to_scan_array:
		if node.is_class(node_class) or node.is_in_group(node_class):
			var object_properties = get_object_properties(property_dict, node, node_class)
			
			dict_to_fill[node.get_path()] = object_properties
			break
	
	for child in node.get_children():
		serialize_level_properties(property_dict, child, dict_to_fill)



# Convert the data to a JSON file
static func save_level_properties_as_json(property_dict: Dictionary, dir: String, level: Node):
	var dict_to_json : Dictionary = {}
	serialize_level_properties(property_dict, level, dict_to_json)
	
	var json_file = File.new()
	var _err = json_file.open(dir + "/" + level.name + ".json", File.WRITE)
	
	json_file.store_line(to_json(dict_to_json))
	json_file.close()


# Take an object, find every properties needed in it and retrun the data as a dict
static func get_object_properties(property_dict: Dictionary, object : Object, classname : String) -> Dictionary:
	var property_list : Array = property_dict[classname]
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


# Delete the .json temporary saves
static func delete_level_temp_saves(dir_path: String, level_name: String):
	var dir = Directory.new()
	var json_path : String = dir_path + level_name + ".json"
	
	if dir.file_exists(json_path):
		dir.remove(json_path)
