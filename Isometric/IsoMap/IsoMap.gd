tool
extends Node2D
class_name IsoMap

# A base class to handle an iso IsoMap
# An iso IsoMap must be the parent of as many IsoMapLayer as your IsoMap has grounds (altitude levels)

enum SLOPE_TYPE {
	NONE,
	SLOPE_LEFT,
	SLOPE_RIGHT
}

onready var pathfinding = $Pathfinding
onready var layer_0_node = $Layer

var layer_array : Array

var grounds : PoolVector3Array = []
var walkable_cells : PoolVector3Array = []
var obstacles : Array = [] setget set_obstacles, get_obstacles

var is_ready : bool = false

signal map_generation_finished

#### ACCESSORS ####

func set_obstacles(array: Array):
	if array != obstacles:
		obstacles = array
		walkable_cells = pathfinding.set_walkable_cells(grounds)
		pathfinding.connect_walkable_cells(walkable_cells, owner.active_actor)

func get_obstacles() -> Array:
	return obstacles


#### BUILT IN ####

func _ready():
	if Engine.editor_hint:
		return
	
	# Store every layers in the layer_ground_array
	for child in get_children():
		if child is IsoMapLayer:
			layer_array.append(child)
	
	init_object_grid_pos()
	
	# Store all the passable cells into the array grounds
	grounds = fetch_ground()
	
	yield(owner, "ready")
	
	var _err = EVENTS.connect("iso_object_cell_changed", self, "on_iso_object_cell_changed")
	_err = EVENTS.connect("cursor_world_pos_changed", self, "on_cursor_world_pos_changed")
	_err = EVENTS.connect("iso_object_removed", self, "_on_iso_object_removed")
	
	# Store all the passable cells into the array walkable_cells_list, 
	# by checking all the cells in the IsoMap to see if they are not an obstacle
	walkable_cells = pathfinding.set_walkable_cells(grounds)
	
	# Create the connections between all the walkable cells
	pathfinding.connect_walkable_cells(walkable_cells, owner.active_actor)
	
	for obj in get_tree().get_nodes_in_group("IsoObject"):
		obj.set_current_cell(get_pos_highest_cell(obj.position))
	
	is_ready = true
	
	emit_signal("map_generation_finished")



#### LOGIC ####


# Give every actor, his default grid pos
func init_object_grid_pos():
	yield(owner, "ready")
	
	for object in get_tree().get_nodes_in_group("IsoObject"):
		object.set_current_cell(get_pos_highest_cell(object.position))



# Return the cell in the ground z grid pointed by the given position
func world_to_ground_z(pos : Vector2, z : int = 0):
	pos.y -= z * 16
	return layer_array[z].world_to_map(pos)


# Return the layer at the given height
func get_layer(height: int) -> IsoMapLayer:
	return layer_array[height]


# Return the id of the layer at the given height
func get_layer_id(height: int) -> int:
	return get_layer(height).get_index()



# Return the actor or obstacle placed on the given cell
# Return null if the cell is empty
func get_object_on_cell(cell: Vector3) -> IsoObject:
	var objects_array = get_tree().get_nodes_in_group("Allies")
	objects_array += get_tree().get_nodes_in_group("Enemies")
	objects_array += $Interactives/Obstacles.get_children()
	
	for object in objects_array:
		if object.get_current_cell() == cell:
			return object
	
	return null



# Take an array of 2D cells and convert it to 3D cells using the height IsoMap
# Each cell returned in the array is the highest at the given 2D position
func array2D_to_grid_cells(line2D: Array) -> PoolVector3Array:
	var cell_array : PoolVector3Array = []
	for point in line2D:
		var cell = find_2D_cell_in_grounds(point)
		if cell != Vector3.INF:
			cell_array.append(cell)
	
	return cell_array


# Take a cell and return its world position
func cell_to_world(cell: Vector3) -> Vector2:
	var pos = layer_0_node.map_to_world(Vector2(cell.x, cell.y))
	pos.y -= cell.z * 16 - 8
	return pos


# Take an array of cells, and return an array of corresponding world positions
func cell_array_to_world(cell_array: PoolVector3Array) -> PoolVector2Array:
	var pos_array : PoolVector2Array = []
	for cell in cell_array:
		var new_pos = cell_to_world(cell)
		if !new_pos in pos_array:
			pos_array.append(new_pos)
	
	return pos_array



# Return the highest layer where the given cell is used
# If the given cell is nowhere: return -1
func get_cell_highest_layer(cell : Vector2) -> int:
	for i in range(layer_array.size() - 1, -1, -1):
		if cell in layer_array[i].get_used_cells():
			return i
	return -1


func get_cell_slope_type(cell: Vector3) -> int:
	var layer : IsoMapLayer = get_layer(int(round(cell.z)))
	var tileset : TileSet = layer.get_tileset()
	var tile_id : int = layer.get_cell(int(cell.x), int(cell.y))
	var tile_name = tileset.tile_get_name(tile_id)
		
	if !"slope".is_subsequence_ofi(tile_name) && !"stair".is_subsequence_ofi(tile_name):
		return SLOPE_TYPE.NONE
	else:
		if "left".is_subsequence_ofi(tile_name):
			return SLOPE_TYPE.SLOPE_LEFT
		else:
			return SLOPE_TYPE.SLOPE_RIGHT 


# Return an array of cells at the given world position 
# (ie cells that would be displayed at the same position in the screen)
func get_cell_stack_at_pos(world_pos: Vector2) -> PoolVector3Array:
	var cell_stack : PoolVector3Array = []
	var highest_cell = get_pos_highest_cell(world_pos)
	if highest_cell != Vector3.INF:
		cell_stack.append(highest_cell)
	
	for z in range(highest_cell.z - 1, -1, -1):
		var world_pos_adapted = Vector2(world_pos.x, world_pos.y + 16 * z)
		var cell_2D = layer_array[z].world_to_map(world_pos_adapted)
		var cell_3D = Vector3(cell_2D.x, cell_2D.y, z)
		if is_position_valid(cell_3D):
			cell_stack.append(cell_3D)
	
	return cell_stack


# Get the highest cell of every cells in the 2D plan,
# Returns a 3 dimentional coordinates array of cells
func fetch_ground() -> PoolVector3Array:
	var feed_array : PoolVector3Array = []
	for i in range(layer_array.size() - 1, -1, -1):
		for cell in layer_array[i].get_used_cells():
			if find_2D_cell(Vector2(cell.x, cell.y), feed_array) == Vector3.INF:
				var current_cell = Vector3(cell.x, cell.y, i)
				if get_cell_slope_type(current_cell) != 0:
					current_cell -= Vector3(0, 0, 0.5)
				feed_array.append(current_cell)
	
	# Handle bridges
	for i in range(layer_array.size()):
		for child in layer_array[i].get_children():
			var tileset = child.get_tileset()
			for cell in child.get_used_cells():
				var tile_id = child.get_cellv(cell)
				var tile_name = tileset.tile_get_name(tile_id)
				if "Bridge" in tile_name:
					var cell_3D = Vector3(cell.x, cell.y, i)
					if "Left" in tile_name:
						feed_array.append(cell_3D)
						feed_array.append(cell_3D + Vector3(1, 0, 0))
					elif "Right" in tile_name:
						feed_array.append(cell_3D)
						feed_array.append(cell_3D + Vector3(0, 1, 0))
	
	return feed_array



# Return true if the given cell is occupied by an obstacle
func is_cell_in_obstacle(cell: Vector3) -> bool:
	for obst in obstacles:
		if cell == obst.get_current_cell():
			return true
	return false


# Return the highest cell in the grid at the given world position
# Can optionaly find it, starting from a given layer (To ignore higher layers)
func get_pos_highest_cell(pos: Vector2, max_layer: int = 0) -> Vector3:
	var ground_0_cell_2D = layer_0_node.world_to_map(pos)
	
	var nb_grounds = layer_array.size()
	if max_layer == 0 or max_layer > nb_grounds:
		max_layer = nb_grounds
		
	for i in range(max_layer - 1, -1, -1):
		var current_cell_2D = ground_0_cell_2D + Vector2(i, i)
		var current_cell_3D = Vector3(current_cell_2D.x, current_cell_2D.y, i)
		
		if current_cell_3D in grounds:
			return current_cell_3D
	return Vector3.INF



# Check if a position is valid, return true if it is, false if it is not
func is_position_valid(cell: Vector3) -> bool:
	var no_obstacle : bool = !is_cell_in_obstacle(cell)
	var inside_boundes : bool = !is_outside_map_bounds(cell)
	var is_walkable : bool = cell in walkable_cells
	var is_slope = int((cell.z) == cell.z)
	
	var is_valid = no_obstacle && inside_boundes && is_walkable
	
	if !is_slope && !is_valid:
		return is_position_valid(cell - Vector3(0, 0, 0.5))
	else:
		return is_valid


# Return true if the given cell is outside the IsoMap bounds
func is_outside_map_bounds(cell: Vector3):
	return !(cell in grounds)


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


#### SIGNAL RESPONSES ####

func on_iso_object_cell_changed(_iso_object: IsoObject):
	pass

func _on_iso_object_removed(iso_object: IsoObject):
	if !iso_object.is_passable():
		obstacles.erase(iso_object)
