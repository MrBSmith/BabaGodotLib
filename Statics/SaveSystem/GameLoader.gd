extends Node
class_name GameLoader


static func load_save_slot(save_dir_path: String, slot_id : int, progression: Node) -> void:
	var config_file = load_save_config_file(save_dir_path, slot_id)
	var input_mapper = InputMapper.new()

	for section in config_file.get_sections():
		match(section):
			"audio":
				#set audio settings
				for key in config_file.get_section_keys(section):
					var value = config_file.get_value(section, key)
					var bus_id = AudioServer.get_bus_index(key.capitalize())
					AudioServer.set_bus_volume_db(bus_id, value)
			"controls":
				#set controls settings
				for action_name in config_file.get_section_keys(section):
					var value = config_file.get_value(section, action_name)
					input_mapper.remap_action_key(action_name, [value])
			"progression":
				for key in config_file.get_section_keys(section):
					var value = config_file.get_value(section, key)
					progression.set(key, value)


# Load the settings found in the ConfigFile settings.cfg at given path (default res://saves/save1/2/3
static func load_save_config_file(dir: String, slot_id : int) -> ConfigFile:
	var save_path : String = find_corresponding_save_file(dir, slot_id)
	if save_path == "":
		push_error("There is no save with id " + String(slot_id))
		return null

	return load_config_file(save_path)


static func load_config_file(cfg_file_path: String) -> ConfigFile:
	var config_file = ConfigFile.new()
	var error = config_file.load(cfg_file_path)
	if error == OK:
		return config_file
	else:
		push_error("Failed to load settings cfg file at path %s. error code : %d" % [cfg_file_path, error])
		return null


# This method will return the path of the save file that has been found according to the specified save_id
static func find_corresponding_save_file(dir_path: String, save_id : int) -> String:
	var config_file = ConfigFile.new()
	for dir in DirNavHelper.fetch_dir_content(dir_path, DirNavHelper.DIR_FETCH_MODE.DIR_ONLY):
		var cfg_path = dir_path + "/" + dir + "/settings.cfg"
		var error = config_file.load(cfg_path)

		if error == OK:
			var file_save_id : int = config_file.get_value("system", "slot_id")
			if save_id == file_save_id:
				return cfg_path
		else:
			push_error("Failed to load settings cfg file with path %s. error code : %d" % [cfg_path, error])
	return ""


static func find_save_slot(dir_path: String, save_id : int) -> String:
	var cfg_file_path = find_corresponding_save_file(dir_path, save_id)
	return cfg_file_path.replacen("/settings.cfg", "")


static func find_first_empty_slot(dir_path: String, max_slots: int) -> int:
	for i in range(max_slots):
		var slot_path = find_corresponding_save_file(dir_path, i + 1)
		if slot_path == "":
			return i + 1
	return -1


static func get_save_time(save_dir: String, save_id: int, time_component_array: Array = ["day", "month", "year", "hour", "minute"]) -> String:
	var save_time_dict = get_save_property_value(save_dir, "time", save_id)
	var save_time := ""
	for component in time_component_array:
		save_time += str(save_time_dict.get(component))
		var sufix = ""
		
		match(component):
			"day", "month" : sufix = "/"
			"year": sufix = " "
			"hour": sufix = "h"
			"minute": sufix= ""
		
		save_time += sufix
	return save_time


static func find_first_save_file(dir_path: String, max_slots: int) -> int :
	for i in range(max_slots):
		var slot_path = find_corresponding_save_file(dir_path, i + 1)
		if slot_path != "":
			return i + 1
	return -1


static func get_saves_count(saves_path: String) -> int:
	return DirNavHelper.fetch_dir_content(saves_path, DirNavHelper.DIR_FETCH_MODE.DIR_ONLY).size()


# Get a save's specific property value according to a given property_name
# Args : saves directory, property_name, save id
# Output : return the value of the save's asked property
static func get_save_property_value(dir: String, property_name : String, save_id : int):
	var save_path : String
	var config_file = ConfigFile.new()

	save_path = find_corresponding_save_file(dir, save_id)
	var error = config_file.load(save_path)
	if error == OK:
		return get_cfg_property_value(config_file, property_name)
	else:
		push_error("Failed to load settings cfg file with save id " + String(save_id) + " . error code : " + str(error))
		return null


# Take a config file and returns the value of the given property_name
# This method is not specific to any save, so that any configfile can be loaded
# The config file have to be loaded before
static func get_cfg_property_value(config_file: ConfigFile, property_name: String):
	for section in config_file.get_sections():
		for key in config_file.get_section_keys(section):
			if key == property_name:
				return config_file.get_value(section, key)
	return null
