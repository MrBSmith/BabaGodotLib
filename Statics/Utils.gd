extends Object
class_name Utils

enum {
	CLOCKWISE,
	COUNTER_CLOCKWISE
}

const DIRECTIONS_4 : Dictionary = {
	"Up": Vector2.UP,
	"Right": Vector2.RIGHT,
	"Down": Vector2.DOWN,
	"Left": Vector2.LEFT
}

const DIRECTIONS_8 : Dictionary = {
	"Up": Vector2.UP,
	"UpRight": Vector2(1, -1),
	"Right": Vector2.RIGHT,
	"DownRight": Vector2.ONE,
	"Down": Vector2.DOWN,
	"DownLeft": Vector2(-1, 1),
	"Left": Vector2.LEFT,
	"UpLeft": Vector2(-1, -1)
}


# Finds the given wanted_key in the given dict and returns its id
# You can operate a case sensitive search or not based on case_sensitive value
static func dict_find_key(dict: Dictionary, wanted_key: String, case_sensitive: bool = true) -> int:
	for i in range(dict.keys().size()):
		var key = dict.keys()[i]
		if case_sensitive:
			if key == wanted_key:
				return i
		else:
			if key.nocasecmp_to(wanted_key) == 0:
				return i
	return -1


# Finds the first key that matches the given value in the given Dictionary and returns it
static func dict_find_key_by_value(dict: Dictionary, value) -> String:
	var id = dict.values().find(value)
	return dict.keys()[id]


static func array_get_rdm_element(array: Array):
	if array.empty():
		return null
	
	return array[randi() % array.size()]


# Find the name of the given direction and returns it as a String
static func find_dir_name(dir: Vector2) -> String:
	for i in range(DIRECTIONS_8.size()):
		if dir.is_equal_approx(DIRECTIONS_8.values()[i]):
			return DIRECTIONS_8.keys()[i]
	return ""


static func find_behaviour(node: Node, behaviour_name: String) -> Behaviour:
	if node.has_meta(behaviour_name):
		return node.get_meta(behaviour_name, null)
	else:
		return null

static func has_behaviour(node: Node, behaviour_name: String) -> bool:
	return node.has_meta(behaviour_name)


static func range_wrapi(init_val: int, nb_values: int, min_val: int, max_val: int, increment: int = 1) -> Array:
	var range_array = range(0, nb_values, increment)
	var output_array = []
	for val in range_array:
		output_array.append(wrapi(init_val + val, min_val, max_val))
	
	return output_array


static func trim_image(image: Image) -> Image:
	var smallest_x = INF
	var smallest_y = INF
	var biggest_x = -1
	var biggest_y = -1
	
	image.lock()
	
	for i in range(2):
		var w_array = range(image.get_width()) if i == 0 else range(image.get_width() - 1, 1, -1)
		var h_array = range(image.get_height()) if i == 0 else range(image.get_height() - 1, 1, -1)
		
		for w in w_array:
			var found = false
			for h in h_array:
				var pixel = image.get_pixel(w, h)
				if pixel.a != 0.0:
					if i == 0:
						if w < smallest_x && smallest_x == INF: 
							smallest_x = w
							found = true 
					else:
						if w > biggest_x && biggest_x == -1: 
							biggest_x = w
							found = true
				if found:
					break
			if found:
				break
		
		for h in h_array:
			var found = false
			for w in w_array:
				var pixel = image.get_pixel(w, h)
				if pixel.a != 0.0:
					if i == 0:
						if h < smallest_y && smallest_y == INF : 
							smallest_y = h
							found = true
					else:
						if h > biggest_y && biggest_y == -1: 
							biggest_y = h
							found = true
				if found:
					break
			if found:
				break
	
	
	var output_img = Image.new()
	output_img.create(biggest_x - smallest_x + 1, biggest_y - smallest_y + 1, false, Image.FORMAT_RGBA8)
	output_img.blit_rect(image, Rect2(smallest_x, smallest_y, biggest_x, biggest_y), Vector2.ZERO)
	return output_img


static func fetch_first(node: Node, wanted_class: String) -> Node:
	for child in node.get_children():
		if child.is_class(wanted_class):
			return child
	return null


static func fetch(node: Node, wanted_class: String) -> Array:
	var array = []
	for child in node.get_children():
		if child.is_class(wanted_class):
			array.append(child)
	return array


# Search for direct children possesing a given behaviour type, and return the found behaviours
static func fetch_behaviours(node: Node, wanted_behaviour: String) -> Array:
	var behaviour_array = [] 
	
	for child in node.get_children():
		var behaviour = find_behaviour(child, wanted_behaviour)
		if behaviour:
			behaviour_array.append(behaviour)
	
	return behaviour_array


static func fetch_recursive(node: Node, wanted_class: String, array: Array = []) -> Array:
	for child in node.get_children():
		if child.is_class(wanted_class) && not child in array:
			array.append(child)
		
		if child.get_child_count() > 0:
			var __ = fetch_recursive(child, wanted_class, array)
	
	return array

# Find an autoload with the given name, return null if none where find
static func find_autoload(target_name: String, tree: SceneTree) -> Node:
	for node in tree.get_root().get_children():
		if node.name == target_name:
			return node
		else:
			for child in node.get_children():
				if child.name == target_name:
					return child
	return null

# Takes a node, and a class path structured this way:
# class_a/class_b/class_c...

# Find direct or indirect children of the given node that respect given the path of classes
# Then returns it in an array
static func fetch_from_class_path(node: Node, class_path: String, ignored_classes := PoolStringArray(), class_as_group: bool = false, array : Array = []) -> Array:
	var class_array = class_path.split("/")
	
	if class_array.empty():
		push_error("The fetch_from_class_path method should never have an empty class_path, abort")
		return []
	
	var first_class = class_array[0]
	class_array.remove(0)
	var new_class_path = class_array.join("/")
	
	for _class in ignored_classes:
		if node.is_class(_class):
			return []
	
	if node.is_class(first_class) or (class_as_group && node.is_in_group(first_class)):
		
		if class_array.empty():
			array.append(node)
		else:
			for child in node.get_children():
				var __ = fetch_from_class_path(child, new_class_path, ignored_classes, class_as_group, array)
	
	return array


static func fetch_scene_instances(node: Node, scene_name: String) -> Array:
	var array = []
	for child in node.get_children():
		var file_path = child.filename
		
		if file_path == "":
			continue
		
		var file_name = file_path.split("/")[-1]
		
		if file_name == scene_name + ".tscn":
			array.append(child)
	
	return array


static func is_obj_of_class_list(obj: Object, class_list: Array) -> bool:
	for cls in class_list:
		if obj.is_class(cls):
			return true
	return false 


static func compute_astar_point_id(cell: Vector2, key: int = 666) -> int:
	return int(abs(cell.x + key * cell.y))

# Returns theorical adjacents cells of the given cell (does not check if the cell exists or not)
static func get_adjacents_cells(cell: Vector2) -> PoolVector2Array:
	var adjs = PoolVector2Array()
	for dir in DIRECTIONS_4.values():
		adjs.append(cell + dir)
	
	return adjs


# Convert a number of milliseconds into a String formated this way:
# mm:ss.msms
static func secs_to_formated_time(seconds: float, nb_digit_after_sec : int = 2) -> String:
	var milliseconds = (seconds - int(seconds))
	var minutes := int(clamp(seconds / 60.0, 0.0, 60.0))
	
	if seconds > 0.0:
		seconds = int(seconds) % 60
	
	var str_min = str(minutes).pad_zeros(2)
	var str_sec = str(seconds).pad_zeros(2)
	
	var final_text = "%s:%s" % [str_min, str_sec]
	
	if nb_digit_after_sec > 0:
		var str_mil_sec = str(milliseconds).pad_decimals(nb_digit_after_sec)
		str_mil_sec = str_mil_sec.split(".")[-1]
		final_text += "." + str_mil_sec
	
	return final_text


static func match_classv(obj: Object, class_array: Array) -> String:
	for cls in class_array:
		if obj.is_class(cls):
			return cls
	return ""


static func get_cfg_game_version(file_path: String) -> String:
	var cfg = ConfigFile.new()
	
	if cfg.load(file_path) == OK:
		return cfg.get_value("system", "game_version", "")
	else:
		push_error("Cannot open the config file at path %s" % file_path)
	
	return ""

# Return true if the game_version of the file is prior to the given version
# Or if the file has no metion of game_version at all
static func cfg_game_verion_is_prior(file_path: String, target_version : String, debug: bool = false) -> bool:
	var file_version = get_cfg_game_version(file_path)
	
	if file_version == "":
		if debug: print("The file has no version mention of any kind: it is considered prior")
		return true
	
	if debug: print("The file version is ", file_version)
	if debug: print("The target_version is ", target_version)
	
	var file_version_splitted = file_version.split(".")
	var target_version_splited = target_version.split(".")
	
	for i in range(target_version_splited.size()):
		if file_version_splitted[i].to_int() > target_version_splited[i].to_int():
			if debug: print("The file version is prior the target_version")
			return false
	
	if debug: print("The file version is NOT prior the target_version")
	return true


#### STRINGS ####

static func to_snake(string: String) -> String:
	return string.to_lower().replacen(" ", "_")


static func to_pascal(string: String) -> String:
	string = string.capitalize()
	string = string.replacen(" ", "")
	return string


#### INPUTS ####

static func input_find_matching_actions(event: InputEvent) -> PoolStringArray:
	var matching_actions = PoolStringArray()
	
	for action in InputMap.get_actions():
		if InputMap.action_has_event(action, event):
			matching_actions.append(action)
	
	return matching_actions


static func key_find_matching_actions(input_event: InputEvent, action_names : Array = []) -> PoolStringArray:
	var matching_actions = PoolStringArray()
	var actions_array = action_names if !action_names.empty() else InputMap.get_actions()
	
	for action in actions_array:
		for event in InputMap.get_action_list(action):
			if event.shortcut_match(input_event):
				matching_actions.append(action)
	
	return matching_actions


static func action_get_keys(action: String) -> PoolStringArray:
	var input_event_array = InputMap.get_action_list(action)
	var keys_array = PoolStringArray()
	
	for event in input_event_array:
		keys_array.append(event.as_text())
	
	return keys_array


static func get_input_event_as_text(event: InputEvent) -> String:
	if event == null:
		return ""
	
	if event is InputEventKey && event.scancode == 0:
		return OS.get_scancode_string(OS.keyboard_get_scancode_from_physical(event.physical_scancode))
	else:
		return event.as_text()


static func are_event_same_input(event_a: InputEvent, event_b: InputEvent) -> bool:
	if event_a == null or event_b == null:
		return false
	
	if event_a.get_class() != event_b.get_class():
		return false
	
	if event_a is InputEventKey:
		return (event_a.scancode == event_b.scancode && event_a.scancode != 0) \
		or (event_a.physical_scancode == event_b.physical_scancode && event_a.physical_scancode != 0)
	
	elif event_a is InputEventJoypadButton:
		return event_a.button_index == event_b.button_index && event_a.device == event_b.device
	
	elif event_a is InputEventJoypadMotion:
		return event_a.axis == event_b.axis && sign(event_a.axis_value) == sign(event_b.axis_value) \
			 && event_a.device == event_b.device
	
	return false


