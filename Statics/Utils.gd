extends Object
class_name Utils

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
	for child in node.get_children():
		if child is Behaviour && child.get_behaviour_type() == behaviour_name:
			return child
	return null


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


static func fetch_recursive(node: Node, wanted_class: String, array: Array = []) -> Array:
	for child in node.get_children():
		if child.is_class(wanted_class) && not child in array:
			array.append(child)
		
		if child.get_child_count() > 0:
			var __ = fetch_recursive(child, wanted_class, array)
	
	return array

# Takes a node, and a class path structured this way:
# class_a/class_b/class_c...

# Find direct or indirect children of the given node that respect given the path of classes
# Then returns it in an array
static func fetch_from_class_path(node: Node, class_path: String, class_as_group: bool = false, array : Array = []) -> Array:
	var class_array = class_path.split("/")
	
	if class_array.empty():
		push_error("The fetch_from_class_path method should never have an empty class_path, abort")
		return []
	
	var first_class = class_array[0]
	class_array.remove(0)
	var new_class_path = class_array.join("/")
	
	if node.is_class(first_class) or (class_as_group && node.is_in_group(first_class)):
		
		if class_array.empty():
			array.append(node)
		else:
			for child in node.get_children():
				var __ = fetch_from_class_path(child, new_class_path, class_as_group, array)
	
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


static func compute_astar_point_id(cell: Vector2, key: int = 666) -> int:
	return int(abs(cell.x + key * cell.y))

# Returns theorical adjacents cells of the given cell (does not check if the cell exists or not)
static func get_adjacents_cells(cell: Vector2) -> PoolVector2Array:
	var adjs = PoolVector2Array()
	for dir in DIRECTIONS_4.values():
		adjs.append(cell + dir)
	
	return adjs


# Convert a number of milliseconds into a String formated this way:
# mm:ss:msms
static func secs_to_formated_time(seconds: float) -> String:
	var milliseconds = (seconds - int(seconds)) * 100
	var minutes := int(clamp(seconds / 60.0, 0.0, 60.0))
	
	if seconds > 0.0:
		seconds = int(seconds) % 60
	
	var str_min = str(minutes).pad_zeros(2)
	var str_sec = str(seconds).pad_zeros(2)
	var str_mil_sec = str(int(milliseconds)).pad_zeros(2)
	
	return "%s:%s:%s" % [str_min, str_sec, str_mil_sec]


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


static func key_find_matching_actions(key_scancode: int, action_names : Array = []) -> PoolStringArray:
	var matching_actions = PoolStringArray()
	var actions_array = action_names if !action_names.empty() else InputMap.get_actions()
	
	for action in actions_array:
		for event in InputMap.get_action_list(action):
			if event is InputEventKey && event.scancode == key_scancode:
				matching_actions.append(action)
	
	return matching_actions


static func action_get_keys(action: String) -> PoolStringArray:
	var input_event_array = InputMap.get_action_list(action)
	var keys_array = PoolStringArray()
	
	for event in input_event_array:
		keys_array.append(event.as_text())
	
	return keys_array
