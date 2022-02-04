extends Node
class_name GameSaver

# Update the settings dictionnary then
# save settings into a config file at the given slot path, create the directory if it doesn't exist
static func save_game(path : String, data: Dictionary):
	if !DirNavHelper.is_dir_existing(path):
		DirNavHelper.create_dir(path)
	
	var __ = save_properties_in_cfg(path + "/settings.cfg", data)


# Save the slot from the given slot_id
static func save_game_in_slot(save_dir_path: String, slot_id : int, data: Dictionary, 
				save_name : String = "save") -> void:
	
	var slot_path = GameLoader.find_corresponding_save_file(save_dir_path, slot_id)
	var slot_name = save_name + String(slot_id) if slot_path == "" else slot_path.split("/")[-2]
	
	save_game(save_dir_path + "/" + slot_name, data)



# Feed a configuration file by giving a dictionary
# Modify the cfg found at the cfg_path, or create it if nothing was found
static func save_properties_in_cfg(cfg_path: String, data: Dictionary) -> int: # -> GlobalScope Error
	var config_file = ConfigFile.new()
	
	if DirNavHelper.is_file_existing(cfg_path):
		config_file.load(cfg_path)
	
	for section in data.keys():
		for property in data[section].keys():
			var value = data[section][property]
			config_file.set_value(section, property, value)
	
	return config_file.save(cfg_path)


# Modify the value of the given property in the given section of the given config file
static func modify_save_property(cfg_path: String, section_name: String, property_name: String, value) -> int: # -> GlobalScope Error:
	var config_file = ConfigFile.new()
	
	if DirNavHelper.is_file_existing(cfg_path):
		config_file.load(cfg_path)
		config_file.set_value(section_name, property_name, value)
	
	return config_file.save(cfg_path)
