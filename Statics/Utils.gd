extends Object
class_name Utils


static func range_wrapi(init_val: int, nb_values: int, min_val: int, max_val: int, increment: int = 1) -> Array:
	var range_array = range(0, nb_values, increment)
	var output_array = []
	for val in range_array:
		output_array.append(wrapi(init_val + val, min_val, max_val))
	
	return output_array
