extends Node
class_name IsoRaycast


# Return the line between two given points 
static func get_line(map_node: IsoMap, origin: Vector3, dest: Vector3) -> PoolVector3Array:
	var line2D = get_line_2D(Vector2(origin.x, origin.y), Vector2(dest.x, dest.y))
	return map_node.array2D_to_grid_cells(line2D)


# Get every cells visible between the origin and the destination
static func get_line_of_sight(map_node: IsoMap, h: int, line: PoolVector3Array) -> PoolVector3Array:
	var origin = line[0] + Vector3(0, 0, h)
	var dest = line[-1]
	var line_xz = get_line_2D(Vector2(origin.x, origin.z), Vector2(dest.x, dest.z))
	var line_of_sight : PoolVector3Array = []
	
	for cell in line:
		if cell == line[0]: continue
		
		var max_z = find_smallest_y(line_xz, cell.x)
		var current_z = cell.z
		var obj : IsoObject = map_node.get_object_on_cell(cell)
		
		if obj != null:
			current_z += obj.get_height()
		
		line_of_sight.append(cell)
		if current_z > max_z: 
			break
	
	return line_of_sight


# Find the point with the given y that has the 
# smallest y and returns the value of the y
static func find_smallest_y(line2D: PoolVector3Array, x: int):
	var smallest_y = INF
	for point in line2D:
		if point.x != x: continue
		if point.y < smallest_y:
			smallest_y = point.y
	return smallest_y


# Get the height dif between the two given cells
static func get_slope(cell1: Vector3, cell2 : Vector3) -> int:
	return int(cell2.z - cell1.z)


# Print the grid of the given size, with x for touched cells, and O for untoched ones
func print_grid(grid_size: int, line: Array):
	for i in range(grid_size):
		var char_line : String = ""
		for j in range(grid_size):
			if Vector2(i, j) in line:
				char_line += "X"
			else:
				char_line += "O"
		print(char_line)


static func get_line_2D(p0: Vector2, p1: Vector2) -> Array:
	var dist_x = p1.x - p0.x
	var nx = abs(dist_x)
	
	if nx == 0: return get_vertical_line(p0, p1)
	
	var dist_y = p1.y - p0.y
	var ny = abs(dist_y)
	
	if ny == 0: return get_horizontal_line(p0, p1)
	
	var sign_x = 1 if dist_x > 0 else -1
	var sign_y = 1 if dist_y > 0 else -1
	
	var p = p0 
	var points : Array = [p]
	
	var ix = 0
	var iy = 0
	
	while(ix < nx || iy < ny):
		if (0.5 + ix) / nx == (0.5 + iy) / ny:
			# Next step is diagonal
			p.x += sign_x
			p.y += sign_y
			ix += 1
			iy += 1
		elif (0.5 + ix) / nx < (0.5 + iy) / ny:
			p.x += sign_x
			ix += 1
		else:
			p.y += sign_y
			iy += 1
		
		points.append(Vector2(p.x, p.y))
	
	return points + [p1]


static func get_horizontal_line(p0: Vector2, p1: Vector2) -> Array:
	var points : Array = []
	for i in range(p0.x, p1.x, sign(p1.x - p0.x)):
		points.append(Vector2(i, p0.y))
	points.append(p1)
	return points


static func get_vertical_line(p0: Vector2, p1: Vector2) -> Array:
	var points : Array = []
	for i in range(p0.y, p1.y, sign(p1.y - p0.y)):
		points.append(Vector2(p0.x, i))
	points.append(p1)
	return points
