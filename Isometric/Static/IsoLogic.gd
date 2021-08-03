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


# Find if a cell x and y is in the heightmap grid, and returns it
# Return Vector3.INF if nothing was found
static func find_2D_cell(cell : Vector2, grid: PoolVector3Array) -> Vector3:
	for grid_cell in grid:
		if (cell.x == grid_cell.x) && (cell.y == grid_cell.y):
			return grid_cell
	return Vector3.INF


# Get the adjacents cells of the given one 
# This method DOSEN'T check if the cells exists. If you need to do so, 
# use get_existing_adjacent_cells instead
static func get_adjacent_cells(cell: Vector2, diagonals: bool = false) -> Array:
	if diagonals:
		return [ 
			Vector2(cell.x + 1, cell.y),
			Vector2(cell.x, cell.y + 1),
			Vector2(cell.x + 1, cell.y + 1),
			Vector2(cell.x - 1, cell.y),
			Vector2(cell.x, cell.y - 1),
			Vector2(cell.x - 1, cell.y - 1),
			Vector2(cell.x + 1, cell.y - 1),
			Vector2(cell.x - 1, cell.y + 1)
		]
	else:
		return [ 
			Vector2(cell.x + 1, cell.y),
			Vector2(cell.x, cell.y + 1),
			Vector2(cell.x - 1, cell.y),
			Vector2(cell.x, cell.y - 1)
		]


# Same thing as get_adjacent_cells but takes a Vector3 as an argument
static func get_v3_adjacent_cells(cell: Vector3, diagonals: bool = false) -> PoolVector3Array:
	var result_array := PoolVector3Array()
	var v2_adjacent = get_adjacent_cells(Vector2(cell.x, cell.y), diagonals)
	
	for adj in v2_adjacent:
		var point = Vector3(adj.x, adj.y, cell.z)
		result_array.append(point)
	return result_array


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
		Vector2(0, -1): return DIRECTION.TOP_RIGHT
		Vector2(-1, 0): return DIRECTION.TOP_LEFT 
	return -1


# Get every cells at the given distance in a 2D plane
static func get_cells_in_circle(origin: Vector3, radius: int) -> PoolVector3Array:
	var cells_in_range := PoolVector3Array()
	var top_left_corner = origin - Vector3(radius, radius, 0)
	
	for i in range(radius * 2 + 1):
		for j in range (radius * 2 + 1):
			var cell = top_left_corner + Vector3(i, j, 0)
			var dist = iso_2D_dist(origin, cell)
			if dist <= radius:
				cells_in_range.append(cell)
	
	return cells_in_range


# Get every cells at the given distance in a 3D space
static func get_cells_in_sphere(origin: Vector3, radius: int) -> PoolVector3Array:
	var cells_in_range := PoolVector3Array()
	var top_left_corner = origin - Vector3.ONE * radius
	
	for i in range(radius * 2 + 1):
		for j in range(radius * 2 + 1):
			for k in range(radius * 2 + 1):
				var cell = top_left_corner + Vector3(i, j, k)
				var dist = iso_3D_dist(origin, cell)
				if dist <= radius:
					cells_in_range.append(cell)
	
	return cells_in_range


# Returns an 2Darray of cells, each element represent a level of distance from the origin
static func sort_cells_by_dist(origin: Vector3, cells_array: PoolVector3Array) -> Array:
	var output_dict = Dictionary()
	
	for cell in cells_array:
		var dist = iso_3D_dist(origin, cell)
		if output_dict.has(dist):
			output_dict[dist].append(cell)
		else:
			output_dict[dist] = [cell]
	
	return output_dict.values()


static func split_move_path(path: PoolVector3Array, segment_size: int) -> Array:
	var path_a = Array(path)
	var slices_array = []
	#warning-ignore:integer_division
	var nb_sub_path = int(path.size() / segment_size)
	var rest = path.size() % segment_size
	var is_rest = bool(rest)
	
	for i in range(nb_sub_path + 1 * int(is_rest)):
		var nb_elem = segment_size if i < nb_sub_path else rest
		var sub_path = []
		for j in range(nb_elem):
			sub_path.append(path_a[i * segment_size + j])
		slices_array.append(sub_path)
	
	return slices_array
