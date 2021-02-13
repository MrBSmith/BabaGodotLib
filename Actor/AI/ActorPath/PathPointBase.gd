extends Position2D
class_name PathPoint

export var method_name : String = ""
export var argument_array : Array = []

func get_event() -> Array:
	var method_array = []
	method_array.append(method_name)
	method_array += argument_array
	return method_array
