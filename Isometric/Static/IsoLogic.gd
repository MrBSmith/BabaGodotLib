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


# Get the direction of the given dest_cell from the point of view of the origin_cell
# This function only returns one of the four DIRECTION
static func get_cell_direction(origin_cell: Vector3, dest_cell: Vector3) -> int:
	var movement := Vector2(sign(dest_cell.x - origin_cell.x), sign(dest_cell.y - origin_cell.y))
	var dir : int = 0
	
	match(movement):
		Vector2(1, 0): dir = DIRECTION.BOTTOM_RIGHT
		Vector2(0, 1): dir = DIRECTION.BOTTOM_LEFT 
		Vector2(-1, 0): dir = DIRECTION.TOP_LEFT 
		Vector2(0, -1): dir = DIRECTION.TOP_RIGHT 
	
	return dir
