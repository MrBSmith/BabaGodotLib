extends Position2D
class_name PathPoint

# A path point base class used to represent a point in an actor path
# The actor will follow the path, point by point, until he reaches the last one
# Each point in the path can posses an event that trigger a method of the actor

export var method_name : String = ""
export var argument_array : Array = []

func _ready() -> void:
	set_as_toplevel(true)


func get_event() -> Array:
	var method_array = []
	method_array.append(method_name)
	method_array += argument_array
	return method_array
