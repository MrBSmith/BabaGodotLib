extends Node
class_name LevelLoader



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
