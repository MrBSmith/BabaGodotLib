extends Node
class_name GameSaver

# Update the settings dictionnary then
# save settings into a config file at the given slot path, create the directory if it doesn't exist
static func save_game(progression: Node, path : String, save_name : String, slot_id : int, settings: Dictionary):
	if !DirNavHelper.is_dir_existing(path):
		DirNavHelper.create_dir(path)
	
	save_properties_in_cfg(path + "/settings.cfg", settings)


# Save the slot from the given slot_id
static func save_game_in_slot(progression: Node, save_dir_path: String, slot_id : int, settings: Dictionary, 
				save_default_name : String = "save") -> void:
	
	var slot_path = GameLoader.find_corresponding_save_file(save_dir_path, slot_id)
	var slot_name = save_default_name + String(slot_id) if slot_path == "" else slot_path.split("/")[-2]
	
	save_game(progression, save_dir_path + "/" + slot_name, slot_name, slot_id, settings)



# Feed a configuration file by giving a dictionary
# Modify the cfg found at the cfg_path, or create it if nothing was found
static func save_properties_in_cfg(cfg_path: String, properties_dict: Dictionary): # -> GlobalScope Error
	var config_file = ConfigFile.new()
	
	if DirNavHelper.is_file_existing(cfg_path):
		config_file.load(cfg_path)
	
	for section in properties_dict.keys():
		for property in properties_dict[section].keys():
			var value = properties_dict[section][property]
			config_file.set_value(section, property, value)
	
	return config_file.save(cfg_path)
