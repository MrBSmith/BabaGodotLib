extends Object
class_name Utils


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
