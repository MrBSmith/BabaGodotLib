extends Node
class_name GameSaver

# A static class that saves the game in it current state
# Use save_game_in_slot() to create a folder in the given path container a .cfg file storing the data of the game
# Alternatively you can use save_game() if you already know the path of the save folder

# If you know the path of the .cfg file in the folder, you can write the data of the save in it using
# save_properties_in_cfg

# modify_save_property() is usefull when you want to change a property in the .cfg file without rewriting all its content


# The save folder must be structured like the following:
# saves/
# 	save1/
# 		settings.cfg
# 		...
# 	save2/
# 		settings.cfg
#		...etc


# Save the slot from the given slot_id
static func save_game_in_slot(save_dir_path: String, slot_id : int, data: Dictionary, 
				save_name : String = "save") -> void:
	
	var slot_name = save_name + String(slot_id)
	
	if !DirNavHelper.is_dir_existing(save_dir_path):
		DirNavHelper.create_dir(save_dir_path)
	
	var save_file_path = save_dir_path + "/" + slot_name + ".cfg"
	
	var __ = save_properties_in_cfg(save_file_path, data)


# Feed a configuration file by giving a dictionary
# Modify the cfg found at the cfg_path, or create it if nothing was found
static func save_properties_in_cfg(cfg_path: String, data: Dictionary, properties_to_write : Array = []) -> int: # -> GlobalScope Error
	var config_file = ConfigFile.new()
	
	if properties_to_write.empty():
		properties_to_write = data.keys()
	
	if DirNavHelper.is_file_existing(cfg_path):
		config_file.load(cfg_path)
	
	for section in properties_to_write:
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
