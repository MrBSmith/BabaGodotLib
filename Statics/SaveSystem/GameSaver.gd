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
static func save_settings(path : String, save_name : String):
	settings_update_keys(GAME._settings, save_name)
	for section in GAME._settings.keys():
		for key in GAME._settings[section]:
			GAME._config_file.set_value(section, key, GAME._settings[section][key])
	
	GAME._config_file.save(path + "/settings.cfg")

