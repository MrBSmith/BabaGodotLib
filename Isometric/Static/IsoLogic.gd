extends Object
class_name IsoLogic

enum DIRECTION{
	BOTTOM_RIGHT,
	BOTTOM_LEFT,
	TOP_LEFT,
	TOP_RIGHT
}

#### LOGIC ####


# Get the direction of the given dest_cell from the point of view of the origin_cell
# This function only returns one of the four DIRECTION
static func get_cell_direction(origin_cell: Vector3, dest_cell: Vector3) -> int:
	var movement := Vector2(sign(dest_cell.x - origin_cell.x), sign(dest_cell.y - origin_cell.y))
	return vec2_to_dir(movement)


# Returns the direction of the to vector from the perpective of the from vector, on the 2D plane, expressed in Vector2
static func iso_dirV(from: Vector3, to: Vector3) -> Vector2:
	var dist = to - from
	var larger_member = max(abs(dist.x), abs(dist.y))
	var dir = Vector2(sign(dist.x), 0) if larger_member == abs(dist.x) else Vector2(0, sign(dist.y))
	
	return dir


# Returns the direction of the to vector from the perpective of the from vector, on the 2D plane, expressed in DIRECTIOn
static func iso_dir(from: Vector3, to: Vector3) -> int:
	return vec2_to_dir(iso_dirV(from, to))


# Return the distance between the 2 given cells on a 2D plan (x, y), expressed in cells
static func iso_2D_dist(from: Vector3, to: Vector3) -> int:
	var x_dist = abs(to.x - from.x)
	var y_dist = abs(to.y - from.y)

	return int(x_dist + y_dist)


# Return the distance between the 2 given cells in the 3D space, expressed in cells
static func iso_3D_dist(from: Vector3, to: Vector3) -> int:
	var x_dist = abs(to.x - from.x)
	var y_dist = abs(to.y - from.y)
	var z_dist = abs(to.z - from.z)

	return int(x_dist + y_dist + z_dist)


# Convert from a DIRECTION value to a direction expressed as a Vector2
static func dir_to_vec2(dir: int) -> Vector2:
	match(dir):
		DIRECTION.BOTTOM_RIGHT: return Vector2(1, 0)
		DIRECTION.BOTTOM_LEFT: return Vector2(0, 1)
		DIRECTION.TOP_LEFT: return Vector2(0, -1)
		DIRECTION.TOP_RIGHT: return Vector2(-1, 0)
	return Vector2.ZERO


# Convert from a direction expressed as a Vector2 to a DIRECTION value 
static func vec2_to_dir(vec: Vector2) -> int:
	match(vec):
		Vector2(1, 0): return DIRECTION.BOTTOM_RIGHT
		Vector2(0, 1): return DIRECTION.BOTTOM_LEFT 
		Vector2(0, -1): return DIRECTION.TOP_LEFT 
		Vector2(-1, 0): return DIRECTION.TOP_RIGHT 
	return -1
