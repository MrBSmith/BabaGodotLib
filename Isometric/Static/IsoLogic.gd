extends Object
class_name IsoLogic

enum DIRECTION{
	BOTTOM_RIGHT,
	BOTTOM_LEFT,
	TOP_LEFT,
	TOP_RIGHT
}

#### LOGIC ####

# Return every cells at the given dist or more from the origin in the given array
static func get_cells_at_xy_dist(origin: Vector3, dist: int, cells_array: PoolVector3Array) -> PoolVector3Array:
	var cells_at_dist = PoolVector3Array()
	for cell in cells_array:
		if cell == origin: continue
		var x_sum_diff = abs(cell.x - origin.x)
		var y_sum_diff = abs(cell.y - origin.y)
		var dif = x_sum_diff + y_sum_diff
		if dif >= dist:
			cells_at_dist.append(cell)
	return cells_at_dist


static func get_cells_in_straight_line(origin : Vector3, dir: int, length: int, cells_array: PoolVector3Array) -> PoolVector3Array:
	if not dir in DIRECTION:
		print_debug("the given direction: " + String(dir) + "is not valid.")
		return PoolVector3Array()
	
	var cells_in_line = PoolVector3Array()
	var vec_dir = dir_to_vec2(dir)
	
	for i in range(length):
		var cell_2d = Vector2(origin.x, origin.y) + vec_dir * (i + 1)
		for cell in cells_array:
			if cell.x == cell_2d.x && cell.y == cell_2d.y:
				cells_in_line.append(cell)
	
	return cells_in_line


static func get_cell_in_perpendicular_line(origin: Vector3, dir: int, lenght: int, cells_array: PoolVector3Array) -> PoolVector3Array:
	if not dir in DIRECTION or lenght % 2 == 0:
		if lenght % 2 == 0: print_debug("The lenght must be an uneven number")
		else : print_debug("the given direction: " + String(dir) + "is not valid.")
		return PoolVector3Array()
	
	var cells_2D_array := PoolVector2Array()
	var cells_in_line = PoolVector3Array()
	var vec_dir = dir_to_vec2(dir)
	var perpendicular_dir = vec_dir.rotated(0.5)
	
	for i in range(lenght):
		if i == 0:
			cells_2D_array.append(Vector2(origin.x, origin.y) + vec_dir)
		else:
			var offset_amount = int((i - 1) / 2)
			var current_dir = perpendicular_dir if (i - 1) % 2 == 0 else perpendicular_dir.invert()
			cells_2D_array.append(cells_2D_array[0] + current_dir * offset_amount)
	
	for cell in cells_array:
		if Vector2(cell.x, cell.y) in cells_2D_array:
			cells_in_line.append(cell)
	
	return cells_in_line


# Get the direction of the given dest_cell from the point of view of the origin_cell
# This function only returns one of the four DIRECTION
static func get_cell_direction(origin_cell: Vector3, dest_cell: Vector3) -> int:
	var movement := Vector2(sign(dest_cell.x - origin_cell.x), sign(dest_cell.y - origin_cell.y))
	return vec2_to_dir(movement)


static func dir_to_vec2(dir: int) -> Vector2:
	match(dir):
		DIRECTION.BOTTOM_RIGHT: return Vector2.RIGHT
		DIRECTION.BOTTOM_LEFT: return Vector2.DOWN
		DIRECTION.TOP_LEFT: return Vector2.UP
		DIRECTION.TOP_RIGHT: return Vector2.LEFT
	return Vector2.ZERO


static func vec2_to_dir(vec: Vector2) -> int:
	match(vec):
		Vector2(1, 0): return DIRECTION.BOTTOM_RIGHT
		Vector2(0, 1): return DIRECTION.BOTTOM_LEFT 
		Vector2(-1, 0): return DIRECTION.TOP_LEFT 
		Vector2(0, -1): return DIRECTION.TOP_RIGHT 
	return -1
