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


static func vec2_to_vec3(vec2: Vector2, z: float) -> Vector3:
	return Vector3(vec2.x, vec2.y, z)


static func vec2_from_vec3(vec3: Vector3) -> Vector2:
	return Vector2(vec3.x, vec3.y)


static func find_most_top_left_v2(array: PoolVector2Array) -> Vector2:
	var top_left_v = Vector2.INF
	for v in array:
		if v.y < top_left_v.y or (v.y == top_left_v.y && v.x < top_left_v.x):
			top_left_v = v
	return top_left_v


static func find_most_bottom_right_v2(array: PoolVector2Array) -> Vector2:
	var bottom_right_v = -Vector2.INF
	for v in array:
		if -v.y > bottom_right_v.y or (v.y == bottom_right_v.y && v.x > bottom_right_v.x):
			bottom_right_v = v
	return bottom_right_v


static func rect2poly(rect: Rect2) -> PoolVector2Array:
	return PoolVector2Array([
		rect.position,
		rect.position + rect.size * Vector2.RIGHT,
		rect.end,
		rect.position + rect.size * Vector2.DOWN
	])


# This method takes a polygon representing a rectangle and convert it to Rect2
# The polygon must have exactly 4 points, and the points must be 
# disposed as a rectangle or it will result as unexpected behaviours
static func poly2rect(polygon: PoolVector2Array) -> Rect2:
	if polygon.size() != 4:
		push_error("The given polygon doesn't have the right amount of points, it must have exactlty 4 points")
		return Rect2()
	
	var top_left = find_most_top_left_v2(polygon)
	var bottom_right = find_most_bottom_right_v2(polygon)
	
	return Rect2(top_left, bottom_right - top_left)
