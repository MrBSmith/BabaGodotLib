extends Node
class_name VersionChecker

# Return true if the game_version of the file is prior to the given version
# Or if the file has no metion of game_version at all
static func cfg_game_verion_is_prior(file_path: String, target_version : String, debug: bool = false) -> bool:
	var file_version = get_cfg_game_version(file_path)
	
	if file_version == "":
		if debug: print("The file has no version mention of any kind: it is considered prior")
		return true
	
	return verion_is_prior(file_version, target_version)


# Return true if the game_version of the file is prior to the given version
# Or if the file has no metion of game_version at all
static func verion_is_prior(version: String, target_version: String) -> bool:
	var version_splitted = version.split(".")
	var target_version_splited = target_version.split(".")
	
	if version == target_version:
		return false
	
	for i in range(target_version_splited.size()):
		if version_splitted[i].to_int() > target_version_splited[i].to_int():
			return false
	
	return true


static func get_cfg_game_version(file_path: String, section := "system", key := "game_version") -> String:
	var cfg = ConfigFile.new()
	
	if cfg.load(file_path) == OK:
		return cfg.get_value(section, key, "")
	else:
		push_error("Cannot open the config file at path %s" % file_path)
	
	return ""
