extends Node
class_name GameSaver

# Get audio and controls project settings and set them into a dictionary.
# This dictionary _settings will be used later to save and load anytime a user wishes to
static func settings_update_keys(settings_dictionary : Dictionary, save_name : String = ""):
	for section in settings_dictionary:
			match(section):
				"system":
					settings_dictionary[section]["time"] = OS.get_datetime()
					settings_dictionary[section]["save_name"] = save_name
				"audio":
					for key in settings_dictionary[section]:
						var bus_id = AudioServer.get_bus_index(key.capitalize())
						if str(AudioServer.get_bus_volume_db(bus_id)) == "-1.#INF":
							AudioServer.set_bus_volume_db(bus_id, -100)
						settings_dictionary[section][key] = AudioServer.get_bus_volume_db(bus_id)
				"controls":
					for key in settings_dictionary[section]:
						settings_dictionary[section][key] = InputMap.get_action_list(key)[0].scancode
				"progression":
					for key in settings_dictionary[section]:
						settings_dictionary[section][key] = GAME.progression.get(key)


static func settings_update_save_name(settings_dictionary  : Dictionary, save_name : String):
	settings_dictionary["system"]["save_name"] = save_name


# Save settings into a config file : res://saves/save1/2/3
static func save_game(path : String, save_name : String):
	if !DirNavHelper.is_dir_existing(path):
		var parent_path = path.replacen("/" + save_name, "")
		DirNavHelper.create_dir(parent_path, save_name)
	
	#### DECOUPLE THIS FROM GAME ####
	settings_update_keys(GAME._settings, save_name)
	for section in GAME._settings.keys():
		for key in GAME._settings[section]:
			GAME._config_file.set_value(section, key, GAME._settings[section][key])
	
	GAME._config_file.save(path + "/settings.cfg")


static func save_game_in_slot(save_dir_path: String, slot_id : int) -> void:
	var slot_paths_array = DirNavHelper.fetch_dir_content(save_dir_path, DirNavHelper.DIR_FETCH_MODE.DIR_ONLY)
	if slot_id < slot_paths_array.size() - 1:
		push_error("The given slot_id doesn't exist")
		return
		
	var slot_name = ""
	var slot_path = GameLoader.find_corresponding_save_file(save_dir_path, slot_id)
	if slot_path == "":
		slot_name = GAME.SAVEDFILE_DEFAULT_NAME + String(slot_id)
	else:
		slot_name = slot_path.split("/")[-1]
	
	save_game(save_dir_path + "/" + slot_name, slot_name)
