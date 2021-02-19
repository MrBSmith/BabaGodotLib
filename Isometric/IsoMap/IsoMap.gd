tool
extends Node2D
class_name IsoMap

# A base class to handle an iso IsoMap
# An iso IsoMap must be the parent of as many IsoMapLayer as your IsoMap has grounds (altitude levels)

var grounds : PoolVector3Array = []

#### LOGIC ####


# Find if a cell x and y is in the heightmap grid, and returns it
# Return Vector3.INF if nothing was found
static func find_2D_cell(cell : Vector2, grid: PoolVector3Array) -> Vector3:
	for grid_cell in grid:
		if (cell.x == grid_cell.x) && (cell.y == grid_cell.y):
			return grid_cell
	return Vector3.INF


func find_2D_cell_in_grounds(cell: Vector2) -> Vector3:
	return find_2D_cell(cell, grounds)


# Get the adjacent cells of the given one
func get_existing_adjacent_cells(cell: Vector3) -> PoolVector3Array:
	var adjacents : PoolVector3Array = []
	var relatives = get_adjacent_cells(cell)
	
	for relative_cell in relatives:
		var adj = find_2D_cell(relative_cell, grounds)
		if adj != Vector3.INF:
			adjacents.append(adj)
	
	return adjacents



# Get the adjacents cells of the given one 
# This method DOSEN'T check if the cells exists. If you need to do so, 
# use get_existing_adjacent_cells instead
static func get_adjacent_cells(cell: Vector3) -> Array:
	return [ 
		Vector2(cell.x + 1, cell.y),
		Vector2(cell.x, cell.y + 1),
		Vector2(cell.x - 1, cell.y),
		Vector2(cell.x, cell.y - 1)
	]


# Count the number of layers
func count_layers() -> int:
	var counter : int = 0
	for child in get_children():
		if child is IsoMapLayer:
			counter += 1
	return counter


# Return the next layer child of the given IsoMap, starting from the given index
func get_next_layer(index : int = 0) -> IsoMapLayer:
	var children = get_children()
	var nb_map_children = children.size()
	if index >= nb_map_children:
		return null
	
	for i in range(index + 1, nb_map_children):
		if children[i] is IsoMapLayer:
			return children[i]
	return null


# Return the next layer child of the given IsoMap, starting from the given index
func get_previous_layer(index : int = 0) -> IsoMapLayer:
	var children = get_children()
	for i in range(index - 1, -1, -1):
		if children[i] is IsoMapLayer:
			return children[i]
	return null


# Return the first layer of the given IsoMap
func get_first_layer() -> IsoMapLayer:
	for child in get_children():
		if child is IsoMapLayer:
			return child
	return null


# Return the last layer of the given IsoMap
# Alias for get_previous_layer(get_child_count())
func get_last_layer() -> IsoMapLayer:
	return get_previous_layer(get_child_count())
