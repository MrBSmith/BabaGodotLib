extends Node
class_name GameLoader

const debug : bool = false

# Load the settings found in the ConfigFile settings.cfg at given path (default res://saves/save1/2/3
static func load_settings(dir: String, slot_id : int):
	var inputmapper = InputMapper.new()

	var save_name : String = find_corresponding_save_file(dir, slot_id)

	if save_name == "":
		return
	
	var save_path : String = dir + "/" + save_name + "/"
	var savecfg_path : String = dir + "/" + save_name + "/settings.cfg"
	
	var error = GAME._config_file.load(savecfg_path)

	if error == OK:
		if debug:
			print("SUCCESSFULLY LOADED SETTINGS CFG FILE. SUCCESS CODE : " + str(error))
			print("From GameSaver.gd : Method Line 87 - Print Line 102+103")
		for section in GAME._config_file.get_sections():
			match(section):
				"audio":
					#set audio settings
					for audio_keys in GAME._config_file.get_section_keys(section):
						AudioServer.set_bus_volume_db(AudioServer.get_bus_index(audio_keys.capitalize()), GAME._config_file.get_value(section, audio_keys))
				"controls":
					#set controls settings
					for control_keys in GAME._config_file.get_section_keys(section):
						inputmapper.change_action_key(control_keys, GAME._config_file.get_value(section, control_keys))
				"gameplay":
					for keys in GAME._config_file.get_section_keys(section):
						match(keys):
							"level_id": GAME.progression.set_level(GAME._config_file.get_value(section, keys))
							"checkpoint_reached": GAME.progression.set_checkpoint(GAME._config_file.get_value(section, keys))
							"xion": GAME.progression.set_xion(GAME._config_file.get_value(section, keys))
							"gear": GAME.progression.set_gear(GAME._config_file.get_value(section, keys))
				_:
					pass
	else:
		if debug:
			print("FAILED TO LOAD SETTINGS CFG FILE. ERROR CODE : " + str(error))
		return
	
	return save_path


# This method will return the path of the save file that has been found according to the specified save_id
static func find_corresponding_save_file(dir: String, save_id : int) -> String:
	for file in find_all_saves_directories(dir):

		var error = GAME._config_file.load(dir + "/" + file + "/settings.cfg")

		if error == OK:
			var file_save_id : int = GAME._config_file.get_value("system","slot_id")
			if save_id == file_save_id:
				return str(file)
		else:
			if debug:
				print("FAILED TO LOAD SETTINGS CFG FILE. ERROR CODE : " + str(error))
			return ""

	return ""


# This method will return an array of every file considered as a SAVE FILE
static func find_all_saves_directories(dir: String) -> Array:
	var saves_directory = Directory.new()
	var error = saves_directory.open(dir)
	var files = []

	if error == OK:
		if debug:
			print("SUCCESSFULLY LOADED SETTINGS CFG FILE. SUCCESS CODE : " + str(error))
			print("From GameSaver.gd : Method Line 130 - Print Line 137+138")

		saves_directory.list_dir_begin(true, true)
		while true:
			var file = saves_directory.get_next()
			if file == "":
				break
			else:
				files.append(file)
		saves_directory.list_dir_end()

		return files

	else:
		if debug:
			print("FAILED TO LOAD SETTINGS CFG FILE. ERROR CODE : " + str(error))
		return []




static func get_save_cfg_property_value_by_name_and_cfgid(dir: String, cfgproperty_name : String, save_id : int):
	var save_path : String

	save_path = find_corresponding_save_file(dir, save_id)
	
	var savecfg_path : String = dir + "/" + save_path + "/settings.cfg"
	var error = GAME._config_file.load(savecfg_path)
	
	if error == OK:
		if debug:
			print("SUCCESSFULLY LOADED SETTINGS CFG FILE. SUCCESS CODE : " + str(error))
			print("From GameSaver.gd : Method Line 180 - Print Line 192+193")
		for section in GAME._config_file.get_sections():
			for keys in GAME._config_file.get_section_keys(section):
				if keys == cfgproperty_name:
					var property_value = GAME._config_file.get_value(section, keys)
					return property_value
	else:
		if debug:
			print("FAILED TO LOAD SETTINGS CFG FILE. ERROR CODE : " + str(error))
		return ""
	
	return ""

