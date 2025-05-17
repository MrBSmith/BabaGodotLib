extends Node
class_name Directions

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

static func get_nearest_cardinal_direction(dir: Vector2, possible_directions := DIRECTIONS_4.values()) -> Vector2:
	var smallest_dist = INF
	var nearest_dir = Vector2.ZERO
	
	for direction in possible_directions:
		if direction.is_equal_approx(dir):
			return direction
		
		var dist = abs(dir.angle_to(direction))
		
		if dist < smallest_dist:
			smallest_dist = dist
			nearest_dir = direction
	
	return nearest_dir


# Find the name of the given direction and returns it as a String
static func find_dir_name(dir: Vector2) -> String:
	for i in range(DIRECTIONS_8.size()):
		if dir.is_equal_approx(DIRECTIONS_8.values()[i]):
			return DIRECTIONS_8.keys()[i]
	return ""
