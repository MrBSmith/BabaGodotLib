extends Node
class_name LevelSaver

# Find recursivly every wanted nodes, and extract their wanted properties
static func serialize_level_properties(property_dict: Dictionary, current_node : Node, dict_to_fill : Dictionary):
	var classes_to_scan_array = property_dict.keys()
	for child in current_node.get_children():
		for node_class in classes_to_scan_array:
			if child.is_class(node_class):
				var object_properties = get_object_properties(property_dict, child, node_class)
				
				dict_to_fill[child.get_path()] = object_properties
				continue
		
		if child.get_child_count() != 0:
			serialize_level_properties(property_dict, child, dict_to_fill)


# Convert the data to a JSON file
static func save_level_properties_as_json(property_dict: Dictionary, dir: String, level : Level):
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
			print("Property : " + property + " could not be found in " + object.name)

	return property_data_dict


# Navigate through the given dir then remove all files and folders there
static func delete_all_level_temp_saves(dir_path: String, display_warning : bool = false):
	var dir = Directory.new()
	
	var folders_array : Array = [dir_path]
	
	for folder in folders_array:
		if dir.open(folder) == OK:
			if display_warning:
				print(folder + " has been opened successfully")
			dir.list_dir_begin(true, true)
			var file_name = dir.get_next()
			if display_warning:
				if file_name == "":
					print("No folder or file detected in " + folder)
			while file_name != "":
				if dir.current_is_dir():
					if display_warning:
						print("Found dir: " + file_name)
					dir.remove(file_name)
				else:
					if display_warning:
						print("Found file: " + file_name)
					dir.remove(file_name)
				file_name = dir.get_next()
			dir.list_dir_end()
		else:
			print("An error occured when trying to access the path : " + folder)


# Delete the .json temporary saves
static func delete_level_temp_saves(dir_path: String, level_name: String):
	var dir = Directory.new()
	var json_path : String = dir_path + level_name + ".json"
	
	if dir.file_exists(json_path):
		dir.remove(json_path)
