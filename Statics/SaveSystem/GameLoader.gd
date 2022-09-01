extends Node
class_name GameLoader

# A static class, usefull for loading game data

# The save folder must be structured like the following:
# saves/
# 	save1/
# 		settings.cfg
# 		...
# 	save2/
# 		settings.cfg
#		...etc


# Load the content of the .cfg save file located in the save_dir_path folder. 
# The method will fetch the right save based on its slot_id
# It will then apply audio & controls settings; and feed the given progression node with the progression data
static func load_save_slot(save_dir_path: String, slot_id : int, progression: Node = null, players_data: Node = null) -> void:
	var config_file_path = find_corresponding_save_file(save_dir_path, slot_id)
	var config_file = ConfigFile.new()
	config_file.load(config_file_path)
	
	var input_mapper = InputMapper.new()

	for section in config_file.get_sections():
		match(section):
			"audio":
				for key in config_file.get_section_keys(section):
					var value = config_file.get_value(section, key)
					var bus_id = AudioServer.get_bus_index(key.capitalize())
					AudioServer.set_bus_volume_db(bus_id, value)
					
			"controls":
				for action_name in config_file.get_section_keys(section):
					var value = config_file.get_value(section, action_name)
					input_mapper.remap_action_key(action_name, value)
			
			"progression":
				if progression == null:
					print_debug("No progression node passed; progression could not be loaded")
					continue
				
				for key in config_file.get_section_keys(section):
					var value = config_file.get_value(section, key)
					progression.set(key, value)
			
			"players_data":
				if players_data == null:
					print_debug("No players_data node passed; players_data could not be loaded")
					continue
				
				# All the players data are stored in one big dictionnary, so it should always be only one key there
				for key in config_file.get_section_keys(section):
					players_data.players_data_dict = config_file.get_value(section, key)


# Create a ConfigFile object out of the settings.cfg found in the save folder corresponding to the given slot_id.
# the dir argument must be the path to the folder containing all the saves
static func load_save_config_file(dir: String, slot_id : int) -> ConfigFile:
	var save_path : String = find_corresponding_save_file(dir, slot_id)
	if save_path == "":
		push_error("There is no save with id " + String(slot_id))
		return null

	return load_config_file(save_path)


# Create a ConfigFile object out of the settings.cfg found at given path and returns it
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
	for file in DirNavHelper.fetch_dir_content(dir_path, DirNavHelper.DIR_FETCH_MODE.FILE_ONLY):
		var error = config_file.load(file)

		if error == OK:
			var file_save_id : int = config_file.get_value("system", "slot_id")
			if save_id == file_save_id:
				return file
		else:
			push_error("Failed to load the save file with path %s. error code : %d" % [file, error])
	return ""


# Returns the path of the save with the given save_id
# the dir argument must be the path to the folder containing all the saves
static func get_save_name(save_path: String) -> String:
	var path_array = save_path.split("/")
	if path_array.empty():
		push_error("The given path %s isn't a valid save path" % save_path)
		return ""
	
	var file_name = path_array[-1].replace(".cfg", "")
	return file_name


# Loops trough every save folder, and finds the first one to be empty/inexistant
# Returns its id
# Returns -1 if every solt is taken
static func find_first_empty_slot(dir_path: String, max_slots: int) -> int:
	for i in range(max_slots):
		var slot_path = find_corresponding_save_file(dir_path, i + 1)
		if slot_path == "":
			return i + 1
	return -1


# Parses the save time of the save with given id
# Returns it expressed as a string formated like following:
# "day/month/year hour h minute"
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


# Finds the first slot id that doesn't have a corresponding save and returns it
static func find_first_save_file_id(dir_path: String, max_slots: int) -> int:
	for i in range(max_slots):
		var slot_path = find_corresponding_save_file(dir_path, i + 1)
		if slot_path != "":
			return i + 1
	return -1


# Returns the number of save dir
static func get_saves_count(saves_path: String) -> int:
	return DirNavHelper.fetch_dir_content(saves_path, DirNavHelper.DIR_FETCH_MODE.DIR_ONLY).size()


# Returns an array of .cfg file_path found in the given directory
static func get_saves(saves_dir_path: String) -> Array:
	var saves_array = []
	
	for file in DirNavHelper.fetch_dir_content(saves_dir_path, DirNavHelper.DIR_FETCH_MODE.FILE_ONLY):
		if ".cfg" in file:
			saves_array.append(file)
	
	return saves_array


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
