extends Node
class_name LevelLoader


# Load the .json level save, deserialize it, then apply the fetched properties to the level
static func build_level_from_loaded_properties(dir: String, level):
	if !level.is_inside_tree():
		yield(level, "tree_entered")
	
	var level_properties : Dictionary = _load_level_properties_from_json(dir)
	level.apply_loaded_properties(level_properties)


# Load the json file corresponding to the given level_name
# Return a dictionary containing every objects with their path as a key and a property dict as value
# The property dict contains each property name as key and property value as value
static func _load_level_properties_from_json(dir: String) -> Dictionary:
	var loaded_level_properties : Dictionary = {}
	var loaded_objects : Dictionary = _deserialize_level_properties(dir)
	for object_dict in loaded_objects.keys():
		var property_dict : Dictionary = {}
		for keys in loaded_objects[object_dict].keys():
			if keys == "name":
				continue
			var property_value
			var string_property_value = String(loaded_objects[object_dict][keys])
			match _get_string_value_type(string_property_value):
				"Vector2" : property_value = _get_vector_from_string(string_property_value)
				"int"  : property_value = int(string_property_value)
				"float" : property_value = float(string_property_value)
				"bool" : property_value = _get_bool_from_string(string_property_value)
			property_dict[keys] = property_value
		loaded_level_properties[object_dict] = property_dict
	
	return loaded_level_properties


# Get the .json file, and convert it to a usable dictionary of property
static func _deserialize_level_properties(file_path : String) -> Dictionary:
	var level_properties  : String = ""
	var parsed_data : Dictionary = {}
	var load_file = File.new()
	
	if !load_file.file_exists(file_path):
		return parsed_data
	
	load_file.open(file_path, load_file.READ)
	level_properties = load_file.get_as_text()
	parsed_data = parse_json(level_properties)
	load_file.close()
	
	return parsed_data



# Get the type of a value string (vector2 bool float or int) by checking its content
static func _get_string_value_type(value : String) -> String: 
	if '(' in value: return "Vector2"
	if value.countn('true') == 1 or value.countn('false') == 1: return "bool"
	if '.' in value: return "float"
	return "int"


# Convert String variable to Vector2 by removing some characters and splitting commas return Vector2
static func _get_vector_from_string(string_vector : String) -> Vector2:
	string_vector = string_vector.trim_prefix('(')
	string_vector = string_vector.trim_suffix(')')
	var split_string_array = string_vector.split(',')
	split_string_array[1] = split_string_array[1].trim_prefix(' ')
	return Vector2(float(split_string_array[0]),float(split_string_array[1]))


# Convert String variable containing "true" or "false" to a boolean value
static func _get_bool_from_string(string_bool : String) -> bool:
	return string_bool.countn('true') == 1


# LOADER DEBUG METHOD
# Print the current state of the level data
static func _print_level_data(dict: Dictionary):
	for obj_path in dict.keys():
		for property in dict[obj_path].keys():
			var to_print = property + ": " + String(dict[obj_path][property])
			if property != "name":
				to_print = "	" + to_print
			print(to_print)
