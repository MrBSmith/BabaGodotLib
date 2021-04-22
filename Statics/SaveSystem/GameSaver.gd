extends Node
class_name GameSaver

const debug : bool = false

# Create the directories 
static func create_dirs(dir_path : String, directories_to_create : Array):
	var dir = Directory.new()
	
	if !is_dir_exist(dir_path):
		dir.open("res://")
		dir.make_dir(dir_path)
	
	for directory_to_check in directories_to_create:
		if !is_dir_exist(dir_path + "/" + directory_to_check):
			if debug:
				print("DIRECTORY DOES NOT EXIST. Creating one in " + dir_path + "...")
			dir.open(dir_path)
			dir.make_dir(directory_to_check)
			
			var created_directory_path : String = dir_path + "/" + directory_to_check
			if debug:
				print("Done ! Directory can in be found in : " + created_directory_path)


static func is_dir_exist(dir_path : String) -> bool:
	var dir = Directory.new()
	var dirExist : bool = dir.dir_exists(dir_path)
	return dirExist


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


# Transfer every temp level .json file to the given destination
static func transfer_level_save_to(temp_save_dir: String, dest_dir: String):
	var dir := Directory.new()
	
	if dir.open(temp_save_dir) == OK:
		var err = dir.list_dir_begin(true, true)
		print_debug("dir navigation error code: " + String(err))
		var file = dir.get_next()
		
		while file != "":
			err = dir.copy(temp_save_dir + "/" + file, dest_dir + "/" + file)
			print_debug("dir copy error code: " + String(err))
			file = dir.get_next()
		
		dir.list_dir_end()


static func settings_update_save_name(settings_dictionary  : Dictionary, save_name : String):
	settings_dictionary["system"]["save_name"] = save_name


# Save settings into a config file : res://saves/save1/2/3
static func save_settings(path : String, save_name : String):
	settings_update_keys(GAME._settings, save_name)
	for section in GAME._settings.keys():
		for key in GAME._settings[section]:
			GAME._config_file.set_value(section, key, GAME._settings[section][key])
			
	GAME._config_file.save(path + "/settings.cfg")

