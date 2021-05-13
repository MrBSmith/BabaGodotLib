extends Node
class_name IsoPathfinder

# A basic class for pathfinding handling iso tile based maps with a z componenent (pseudo 3D)
# Feed the Astar algorithm with every tile using the method set_walkable_cells()
# Then connect the cells by calling connect_walkable_cells

# You can then call find_path to find a path between two cells
# You can also call find_reachable_cells to get a PoolVector3Array of reachable cells


onready var astar_node = AStar.new()
onready var map_node = get_parent()

#### ACCESSORS ####

func is_class(value: String): return value == "IsoPathfinder" or .is_class(value)
func get_class() -> String: return "IsoPathfinder"


#### BUILT-IN ####

func _ready() -> void:
	var _err = EVENTS.connect("actor_moved", self, "_on_actor_moved")
	_err = EVENTS.connect("iso_object_removed", self, "_on_iso_object_removed")


#### LOGIC ####

# Determine which cells are walkale and which are not
func set_walkable_cells(cell_array : PoolVector3Array):
	var passable_cell_array : PoolVector3Array = []
	astar_node.clear()

	# Go through all the cells of the IsoMap, and check if they are in the obstacles array
	for cell in cell_array:
		# Add the last cell checked in the array of points we will create in the astar_node
		passable_cell_array.append(cell)

		# Caculate an index for our cell, and add it to the astar_node
		var cell_index = compute_cell_index(cell)
		astar_node.add_point(cell_index, cell)

		# Disable cell where there is an obstacle
		if map_node.is_cell_in_obstacle(cell):
			astar_node.set_point_disabled(cell_index, true)

	return passable_cell_array


# Connect walkables cells together
func connect_walkable_cells(cells_array: PoolVector3Array, active_actor: TRPG_Actor):
	if active_actor == null: return

	var max_height = active_actor.get_jump_max_height()
	for cell in cells_array:
		# Store the current cell's index we are checking in cell_index
		var cell_index = compute_cell_index(cell)

		# Store the four surrounding points of the cell we are checking in cell_relative
		var cell_relative_array = PoolVector2Array([
			Vector2(cell.x + 1, cell.y),
			Vector2(cell.x - 1, cell.y),
			Vector2(cell.x, cell.y + 1),
			Vector2(cell.x, cell.y - 1)])

		# Loop through the for relative points of the current cell
		for cell_relative in cell_relative_array:
			var cell_rel_z = map_node.get_cell2D_highest_z(cell_relative)
			var cell3D_rel = Vector3(cell_relative.x,
								cell_relative.y, cell_rel_z)

			var cell_rel_index = compute_cell_index(cell3D_rel)

			# If the current relative cell is outside the IsoMap,
			# or if it is not inside the astar_node, skip to the next relative
			if map_node.find_2D_cell(cell_relative, cells_array) == Vector3.INF:
				continue
			if not astar_node.has_point(cell_rel_index):
				continue

			var height_dif = cell.z - cell_rel_z

			# If the points are already connected, skip to the next iteration
			if astar_node.are_points_connected(cell_index, cell_rel_index):
				continue

			# If the height diference is too high, continue to the next
			var is_close_enough = height_dif < max_height
			if is_close_enough:
				astar_node.connect_points(cell_index,
						cell_rel_index, true)
			else:
				if cell.z > cell_rel_z:
					astar_node.connect_points(cell_index,
						cell_rel_index, false)



# Retrun the shortest path between two points, or an empty path if there is no path to take to get there
func find_path(start_cell: Vector3, end_cell: Vector3) -> PoolVector3Array:
	var cell_path : PoolVector3Array = []

	# Check if the given start and end points are valid, retrun an empty array if not
	if start_cell == Vector3.INF or end_cell == Vector3.INF:
		cell_path = []
		return PoolVector3Array()

	# Calculate the start and the end cell index
	var start_cell_index = compute_cell_index(start_cell)
	var end_cell_index = compute_cell_index(end_cell)

	# Find a path between this two points, and store it into cell_path
	cell_path = astar_node.get_point_path(start_cell_index, end_cell_index)

	return cell_path


# Find a path between the start_cell and the iso_object (Considering this object as passable)
func find_path_to_reach(start_cell: Vector3, end_cell: Vector3) -> PoolVector3Array:
	var end_cell_id = compute_cell_index(end_cell)
	astar_node.set_point_disabled(end_cell_id, false)
	
	var path = find_path(start_cell, end_cell)
	astar_node.set_point_disabled(end_cell_id, true)
	
	if path != PoolVector3Array():
		path.resize(path.size() - 1)
	
	return path


# Find all the walkable cells and retrun their position
func find_reachable_cells(actor_cell : Vector3, actor_movements : int) -> PoolVector3Array:
	var reachable_cells : PoolVector3Array = [actor_cell]
	var relatives : PoolVector3Array

	for i in range(1, actor_movements + 1):
		# Find the adjacents cells of the current cell
		if i == 1:
			relatives = find_relatives([actor_cell], reachable_cells)
		else:
			relatives = find_relatives(relatives, reachable_cells)

		# Check for every points if it is valid, not already treated
		# and if a path exist between the actor's position and it
		for cell in relatives:
			if map_node.is_position_valid(cell) && !(cell in reachable_cells):
			
				# Get the lenght of the path between the actor and the cursor
				var path_len = len(find_path(actor_cell, cell))
				if path_len > 0 && path_len - 1 <= actor_movements:
					reachable_cells.append(cell)

	return reachable_cells


# Find all the relatives to an array of points, checking if they haven't been treated before,
# and return it in an array
func find_relatives(point_array : PoolVector3Array, reachable_cells: PoolVector3Array) -> PoolVector3Array:
	var result_array : PoolVector3Array = []

	for cell in point_array:
		var point_relative = PoolVector2Array([
		Vector2(cell.x + 1, cell.y),
		Vector2(cell.x - 1, cell.y),
		Vector2(cell.x, cell.y + 1),
		Vector2(cell.x, cell.y - 1)])

		for relative in point_relative:
			# If the current cell asn't been treated yet
			var cell3D = map_node.find_2D_cell(relative, map_node.grounds)
			if not cell3D in reachable_cells:
				result_array.append(cell3D)

	return result_array


# Return the cell index
func compute_cell_index(cell: Vector3):
	return abs(cell.x + map_node.grounds.size() * cell.y)


#### SIGNAL RESPONSES ####

func _on_actor_moved(_actor: TRPG_Actor, from: Vector3, to: Vector3):
	if !map_node.is_cell_in_obstacle(from):
		var id = compute_cell_index(from)
		astar_node.set_point_disabled(id, false)

	var id = compute_cell_index(to)
	astar_node.set_point_disabled(id, true)


func _on_iso_object_removed(iso_object: IsoObject):
	if iso_object.is_class("Obstacle"):
		var cell = iso_object.get_current_cell()
		var cell_id = compute_cell_index(cell)
		astar_node.set_point_disabled(cell_id, false)
