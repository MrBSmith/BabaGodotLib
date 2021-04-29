extends Node
class_name GameLoader


# Load the settings found in the ConfigFile settings.cfg at given path (default res://saves/save1/2/3
static func load_settings(dir: String, slot_id : int) -> String:
	var input_mapper = InputMapper.new()

	var save_name : String = find_corresponding_save_file(dir, slot_id)
	if save_name == "": return ""
	
	var save_path : String = dir + "/" + save_name + "/"
	var save_cfg_path : String = save_path + "settings.cfg"
	
	var error = GAME._config_file.load(save_cfg_path)
	if error == OK:
		for section in GAME._config_file.get_sections():
			match(section):
				"audio":
					#set audio settings
					for key in GAME._config_file.get_section_keys(section):
						var value = GAME._config_file.get_value(section, key)
						var bus_id = AudioServer.get_bus_index(key.capitalize())
						AudioServer.set_bus_volume_db(bus_id, value)
				"controls":
					#set controls settings
					for key in GAME._config_file.get_section_keys(section):
						var value = GAME._config_file.get_value(section, key)
						input_mapper.change_action_key(key, value)
				"progression":
					for key in GAME._config_file.get_section_keys(section):
						var value = GAME._config_file.get_value(section, key)
						GAME.progression.set(key, value)
	else:
		push_error("Failed to load settings cfg file. error code : " + str(error))
		return ""
	
	return save_path


# This method will return the path of the save file that has been found according to the specified save_id
static func find_corresponding_save_file(dir: String, save_id : int) -> String:
	for file in DirNavHelper.fetch_dir_content(dir, DirNavHelper.DIR_FETCH_MODE.DIR_ONLY):

		var error = GAME._config_file.load(dir + "/" + file + "/settings.cfg")

		if error == OK:
			var file_save_id : int = GAME._config_file.get_value("system", "slot_id")
			if save_id == file_save_id:
				return str(file)
		else:
			push_error("Failed to load settings cfg file. error code : " + str(error))
	return ""


static func get_cfg_property_value(dir: String, cfg_property_name : String, save_id : int):
	var save_path : String

	save_path = find_corresponding_save_file(dir, save_id)
	if save_path == "": return ""
	
	var save_cfg_path : String = dir + "/" + save_path + "/settings.cfg"
	var error = GAME._config_file.load(save_cfg_path)
	
	if error == OK:
		for section in GAME._config_file.get_sections():
			for key in GAME._config_file.get_section_keys(section):
				if key == cfg_property_name:
					var property_value = GAME._config_file.get_value(section, key)
					return property_value
	else:
		push_error("Failed to load settings cfg file. error code : " + str(error))
	return ""

