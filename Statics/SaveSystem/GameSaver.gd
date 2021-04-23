extends Node
class_name GameSaver

const debug : bool = false


# Get audio and controls project settings and set them into a dictionary.
# This dictionary _settings will be used later to save and load anytime a user wishes to
static func settings_update_keys(settings_dictionary : Dictionary, save_name : String = ""):
	for section in settings_dictionary:
			match(section):
				"system":
					settings_dictionary[section]["time"] = OS.get_datetime()
					settings_dictionary[section]["save_name"] = save_name
				"audio":
					for keys in settings_dictionary[section]:
						if str(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(keys.capitalize()))) == "-1.#INF":
							AudioServer.set_bus_volume_db(AudioServer.get_bus_index(keys.capitalize()), -100)
						settings_dictionary[section][keys] = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(keys.capitalize()))
				"controls":
					for keys in settings_dictionary[section]:
						settings_dictionary[section][keys] = InputMap.get_action_list(keys)[0].scancode
				"gameplay":
					for keys in settings_dictionary[section]:
						match(keys):
							"level_id":
								settings_dictionary[section][keys] = GAME.progression.get_level()
							"checkpoint_reached":
								settings_dictionary[section][keys] = GAME.progression.get_checkpoint()
							"xion":
								settings_dictionary[section][keys] = GAME.progression.get_xion()
							"gear":
								settings_dictionary[section][keys] = GAME.progression.get_gear()
				_:
					pass


static func settings_update_save_name(settings_dictionary  : Dictionary, save_name : String):
	settings_dictionary["system"]["save_name"] = save_name


# Save settings into a config file : res://saves/save1/2/3
static func save_settings(path : String, save_name : String):
	settings_update_keys(GAME._settings, save_name)
	for section in GAME._settings.keys():
		for key in GAME._settings[section]:
			GAME._config_file.set_value(section, key, GAME._settings[section][key])
			
	GAME._config_file.save(path + "/settings.cfg")

