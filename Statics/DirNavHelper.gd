extends Node
class_name DirNavHelper

const debug : bool = false

enum DIR_FETCH_MODE {
	ALL,
	DIR_ONLY,
	FILE_ONLY
}

# Create the directories 
static func create_dir(dir_path : String):
	var dir = Directory.new()
	
	var dir_path_mod = dir_path.replacen("res://", "")
	var splited_path : PoolStringArray = dir_path_mod.split("/")
	var dir_to_create = splited_path[-1]
	splited_path.remove(splited_path.size() - 1)
	var parent_path = "res://" + splited_path.join("/")
	
	if !is_dir_existing(parent_path):
		dir.open("res://")
		dir.make_dir(parent_path)
	
	if !is_dir_existing(dir_path):
		dir.open(parent_path)
		dir.make_dir(dir_to_create)
		
		if debug:
			print("Done ! Directory can in be found in : " + dir_path)


# Check if the directory at the given path exists or not
static func is_dir_existing(dir_path : String) -> bool:
	var dir = Directory.new()
	return dir.dir_exists(dir_path)


# Check if the file at the given path exists or not
static func is_file_existing(file_path: String) -> bool:
	var dir = Directory.new()
	return dir.file_exists(file_path)


# Check if the give directory is empty or not
static func is_dir_empty(dir_path) -> bool:
	var dir = Directory.new()
	if dir.open(dir_path) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		return file_name == ""
	else:
		push_error("The directory at path " + dir_path + " could'nt be opened")
		return true


# Navigate through the given folder then removes all files and folders inside it
static func empty_folder(dir_path: String, display_warning : bool = false):
	var dir = Directory.new()
	
	if dir.open(dir_path) == OK:
		if display_warning: print(dir_path + " has been opened successfully")
		
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		
		if display_warning:
			if file_name == "":
				push_error("No folder or file detected in " + dir_path)
		
		while file_name != "":
			if display_warning:
				if dir.current_is_dir(): print("Found dir: " + file_name)
				else: push_error("Found file: " + file_name)
			
			if !is_dir_empty(dir_path + "/" + file_name):
				empty_folder(dir_path + "/" + file_name)
			
			dir.remove(file_name)
			file_name = dir.get_next()
		
		dir.list_dir_end()
	else:
		push_error("An error occured when trying to access the path : " + dir_path)


# Empty the given folder, then removes it
static func delete_folder(dir_path: String):
	empty_folder(dir_path)
	var dir = Directory.new()
	if dir.open(dir_path) == OK:
		dir.remove(dir_path)


# Transfer every file in the given folder to the given destination
static func transfer_dir_content(temp_save_dir: String, dest_dir: String):
	var dir := Directory.new()
	
	if dir.open(temp_save_dir) == OK:
		var err = dir.list_dir_begin(true, true)
		if err != OK: print_debug("dir navigation error code: " + String(err))
		var file = dir.get_next()
		
		while file != "":
			err = dir.copy(temp_save_dir + "/" + file, dest_dir + "/" + file)
			if err != OK: print_debug("dir copy error code: " + String(err))
			file = dir.get_next()
		
		dir.list_dir_end()


# Fetch the content of the given dir
# fetch_mode determine if you want to fetch only folders, only files or everything
static func fetch_dir_content(dir_path: String, fetch_mode: int = DIR_FETCH_MODE.ALL) -> Array:
	var dir = Directory.new()
	var error = dir.open(dir_path)
	var files = []

	if error == OK:
		dir.list_dir_begin(true, true)
		var file = dir.get_next()
		
		while file != "":
			if fetch_mode == DIR_FETCH_MODE.DIR_ONLY && !dir.current_is_dir() or \
				fetch_mode == DIR_FETCH_MODE.FILE_ONLY && dir.current_is_dir():
				file = dir.get_next()
				continue

			files.append(file)
			file = dir.get_next()
		
		dir.list_dir_end()

		return files

	else:
		return []
