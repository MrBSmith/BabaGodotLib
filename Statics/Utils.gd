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
	var dir_values_array = DIRECTIONS_8.values()
	var dir_index = dir_values_array.find(dir)
	
	if dir_index == -1:
		return ""
	
	var dir_keys_array = DIRECTIONS_8.keys()
	var dir_key = dir_keys_array[dir_index]
	
	return dir_key


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


