extends Node
class_name GameLoader


# Load the settings found in the ConfigFile settings.cfg at given path (default res://saves/save1/2/3
static func load_config_file(dir: String, slot_id : int) -> ConfigFile:
	var config_file = ConfigFile.new()
	var save_path : String = find_corresponding_save_file(dir, slot_id)
	if save_path == "":
		push_error("There is no save with id " + String(slot_id))
		return null
	
	var error = config_file.load(save_path)
	if error == OK:
		return config_file
	else:
		push_error("Failed to load settings cfg file. error code : " + str(error))
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
			push_error("Failed to load settings cfg file. error code : " + str(error))
	return ""


static func find_save_slot(dir_path: String, save_id : int) -> String:
	var cfg_file_path = find_corresponding_save_file(dir_path, save_id)
	return cfg_file_path.replacen("/settings.cfg", "")


static func find_first_slot_available(dir_path: String, max_slots: int) -> int:
	for i in range(max_slots):
		var slot_path = find_corresponding_save_file(dir_path, i + 1)
		if slot_path == "":
			return i + 1
	return -1


static func get_cfg_property_value(dir: String, cfg_property_name : String, save_id : int):
	var save_path : String
	var config_file = ConfigFile.new()
	
	save_path = find_corresponding_save_file(dir, save_id)
	var error = config_file.load(save_path)
	
	if error == OK:
		for section in config_file.get_sections():
			for key in config_file.get_section_keys(section):
				if key == cfg_property_name:
					var property_value = config_file.get_value(section, key)
					return property_value
	else:
		push_error("Failed to load settings cfg file with save id " + String(save_id) + " . error code : " + str(error))
		return ""

