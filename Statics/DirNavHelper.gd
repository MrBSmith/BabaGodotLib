extends Node
class_name DirNavHelper

const debug : bool = true

enum DIR_FETCH_MODE {
	ALL,
	DIR_ONLY,
	FILE_ONLY
}

# Create the directories
static func create_dir(dir_path : String):
	var dir = Directory.new()
	
	var prefix = _get_path_prefix(dir_path)
	var dir_path_mod = dir_path.replacen(prefix, "")
	var splited_path : PoolStringArray = dir_path_mod.split("/")
	splited_path.remove(splited_path.size() - 1)
	var parent_path = prefix + splited_path.join("/")

	if !is_dir_existing(parent_path):
		var err = dir.make_dir(parent_path)
		if err != OK:
			push_error("Dir at path %s can't be created, error code: %d" % [parent_path, err])
	
	if !is_dir_existing(dir_path):
		var err = dir.make_dir(dir_path)
		if err != OK:
			push_error("Dir at path %s can't be created, error code: %d" % [dir_path, err])


static func _get_path_prefix(path: String) -> String:
	if "//" in path:
		return path.split("/")[0] + "//"
	else:
		return ""


static func read_file_line(path: String) -> String:
	var file = File.new()
	var err = file.open(path, File.READ_WRITE)
	
	if err != OK:
		push_error("file at path %s couldn't be loaded, error code %d" % [path, err])
		return ""
	
	var line = file.get_line()
	file.close()
	
	return line


# Check if the directory at the given path exists or not
static func is_dir_existing(dir_path : String) -> bool:
	var dir = Directory.new()
	var prefix = _get_path_prefix(dir_path)
	dir.open(prefix)
	return dir.dir_exists(dir_path)


# Check if the file at the given path exists or not
static func is_file_existing(file_path: String) -> bool:
	var dir = Directory.new()
	var prefix = _get_path_prefix(file_path)
	var dir_path = prefix if prefix != "" else "res://"
	
	if dir.open(dir_path) == OK:
		return dir.file_exists(file_path)
	else:
		push_error("couldn't open dir at path %s" % dir_path)
		return false


# Check if the give directory is empty or not
static func is_dir_empty(dir_path: String) -> bool:
	var dir = Directory.new()
	
	if dir.open(dir_path) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		return file_name == ""
	else:
		push_error("The directory at path " + dir_path + " couldn't be opened")
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
				push_warning("No folder or file detected in " + dir_path)

		while file_name != "":
			if dir.current_is_dir():
				empty_folder(dir_path + "/" + file_name)
				if display_warning:
					print("Found dir: " + file_name)
			else:
				if display_warning:
					print("Found file: " + file_name)

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
	var dest_dir_savedlevels_path : String = dest_dir + "/saved_levels"

	if dir.open(temp_save_dir) == OK:
		var err = dir.list_dir_begin(true, true)
		if err != OK: push_error("dir navigation error code: " + String(err))
		var file = dir.get_next()

		if !is_dir_existing(dest_dir_savedlevels_path):
			if dir.make_dir(dest_dir_savedlevels_path) != OK:
				push_error("saved_levels directory could not be created in Save Location, stopping transfer process")
				return

		while file != "":
			err = dir.copy(temp_save_dir + "/" + file, dest_dir_savedlevels_path + "/" + file)
			if err != OK: push_error("dir copy error code: " + String(err))
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
