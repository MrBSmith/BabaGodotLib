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

var layers_array : Array setget , get_layers_array

var grounds := PoolVector3Array()
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

func get_obstacles() -> Array: return obstacles

func get_layers_array() -> Array: return layers_array

#### BUILT IN ####

func _ready():
	if Engine.editor_hint:
		return
	# Store all the passable cells into the array grounds
	
	_fetch_layers()
	_init_object_grid_pos()
	_fetch_ground()
	_fetch_obstacles()
	
	yield(owner, "ready")
	
	var _err = EVENTS.connect("iso_object_cell_changed", self, "_on_iso_object_cell_changed")
	_err = EVENTS.connect("cursor_world_pos_changed", self, "_on_cursor_world_pos_changed")
	_err = EVENTS.connect("iso_object_removed", self, "_on_iso_object_removed")
	
	# Store all the passable cells into the array walkable_cells_list, 
	# by checking all the cells in the IsoMap to see if they are not an obstacle
	walkable_cells = pathfinding.set_walkable_cells(grounds)
	
	# Create the connections between all the walkable cells
	pathfinding.connect_walkable_cells(walkable_cells, owner.active_actor)
	
	for obj in get_tree().get_nodes_in_group("IsoObject"):
		obj.set_current_cell(get_pos_highest_cell(obj.position))
		obj.map = self
	
	is_ready = true
	
	emit_signal("map_generation_finished")



#### LOGIC ####

# Get every unpassable object form the IsoObject group 
func _fetch_obstacles():
	var iso_object_array = get_tree().get_nodes_in_group("IsoObject")
	var unpassable_objects : Array = []
	for object in iso_object_array:
		if !object.is_passable():
			unpassable_objects.append(object)
	
	set_obstacles(unpassable_objects)


# Fetch every accessible cells and store it in grounds
func _fetch_ground():
	var feed_array : PoolVector3Array = []
	for i in range(layers_array.size() - 1, -1, -1):
		for cell in layers_array[i].get_used_cells():
			if find_2D_cell(Vector2(cell.x, cell.y), feed_array) == Vector3.INF:
				var current_cell = Vector3(cell.x, cell.y, i)
				
				if get_cell_slope_type(cell, i) != 0:
					current_cell -= Vector3(0, 0, 0.5)
				
				feed_array.append(current_cell)
	
	# Handle bridges
	for i in range(layers_array.size()):
		for child in layers_array[i].get_children():
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
	
	grounds = feed_array


func _fetch_layers():
	for child in get_children():
		if child is IsoMapLayer && not child in layers_array:
			layers_array.append(child)


# Give every actor, his default grid pos
func _init_object_grid_pos():
	yield(owner, "ready")
	
	for object in get_tree().get_nodes_in_group("IsoObject"):
		object.set_current_cell(get_pos_highest_cell(object.position))




#### LAYERS ####


# Return the layer at the given height
func get_layer(height: float) -> IsoMapLayer:
	if height >= layers_array.size():
		return null
	else:
		return layers_array[round(height)]


# Return the id of the layer at the given height
func get_layer_id(height: float) -> int:
	return get_layer(round(height)).get_index()


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


# Takes a world position and a layer id and return the corresponding 2D cell in the given layer
func world_to_layer_2D_cell(pos : Vector2, layer_id : int = 0) -> Vector2:
	pos.y -= layer_id * 16
	return layers_array[layer_id].world_to_map(pos)


# Return the actor or obstacle placed on the given cell
# Works also if the cell is one of the cell the body of the object is in
# Return null if the cell is empty
func get_damagable_on_cell(cell: Vector3) -> TRPG_DamagableObject:
	var damagable_array = get_tree().get_nodes_in_group("IsoObject")
	
	for object in damagable_array:
		if not object is TRPG_DamagableObject:
			continue
		
		var obj_cell = object.get_current_cell()
		
		if obj_cell.x == cell.x && obj_cell.y == cell.y && \
		cell.z >= obj_cell.z && cell.z <= obj_cell.z + object.get_height():
			return object
	return null


# Take an array of 2D cells and convert it to 3D cells using the height IsoMap
# Each cell returned in the array is the highest at the given 2D position
func array2D_to_grid_cells(line2D: Array) -> PoolVector3Array:
	var cell_array : PoolVector3Array = []
	for point in line2D:
		var cell = find_2D_cell(point, grounds)
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


# Return the highest altitude possible at the given 2D position
# If the given cell doesn't exist, return -1
func get_cell2D_highest_z(cell : Vector2) -> float:
	for i in range(layers_array.size() - 1, -1, -1):
		if cell in layers_array[i].get_used_cells():
			if get_cell_slope_type(cell, i) != 0:
				return i - 0.5
			else:
				return float(i)
	return -1.0


# Returns the slope type of the given cell2D in the given layer
func get_cell_slope_type(cell2D: Vector2, layer_id: int) -> int:
	var layer : IsoMapLayer = get_layer(layer_id)
	var tileset : TileSet = layer.get_tileset()
	var tile_id : int = layer.get_cellv(cell2D)
	
	if !(tile_id in tileset.get_tiles_ids()):
		return SLOPE_TYPE.NONE
	
	var tile_name = tileset.tile_get_name(tile_id)
		
	if !"slope".is_subsequence_ofi(tile_name) && !"stair".is_subsequence_ofi(tile_name):
		return SLOPE_TYPE.NONE
	else:
		if "left".is_subsequence_ofi(tile_name):
			return SLOPE_TYPE.SLOPE_LEFT
		else:
			return SLOPE_TYPE.SLOPE_RIGHT 


# Returns the cell type of the given cell3D
func get_cell_slope_type_v3(cell: Vector3) -> int:
	return get_cell_slope_type(Vector2(cell.x, cell.y), int(round(cell.z)))


# Return an array of cells at the given world position 
# (ie cells that would be displayed at the same position in the screen)
# Not to be confused with a stack of tiles at a given 2D grid coordinates
func get_cell_stack_at_pos(world_pos: Vector2) -> PoolVector3Array:
	var cell_stack : PoolVector3Array = []
	var highest_cell = get_pos_highest_cell(world_pos)
	if highest_cell != Vector3.INF:
		cell_stack.append(highest_cell)
	
	for i in range(round(highest_cell.z) - 1, -1, -1):
		var world_pos_adapted = Vector2(world_pos.x, world_pos.y + 16 * i)
		var cell_2D = layers_array[i].world_to_map(world_pos_adapted)
		var cell_3D = Vector3(cell_2D.x, cell_2D.y, i)
		
		if get_cell_slope_type(cell_2D, i) != 0:
			cell_3D -= Vector3(0, 0, 0.5)
		
		if is_position_valid(cell_3D):
			cell_stack.append(cell_3D)
	
	return cell_stack


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
	
	var nb_grounds = layers_array.size()
	if max_layer == 0 or max_layer > nb_grounds:
		max_layer = nb_grounds
		
	for i in range(max_layer - 1, -1, -1):
		var current_cell_2D = ground_0_cell_2D + Vector2(i, i)
		var current_cell_3D = Vector3(current_cell_2D.x, current_cell_2D.y, i)
		
		if get_cell_slope_type(current_cell_2D, i) != 0:
			current_cell_3D -= Vector3(0, 0, 0.5)
		
		if current_cell_3D in grounds:
			return current_cell_3D
		
	return Vector3.INF


# Check if the cell is empty (ie there is no tile nor obstacle on it)
func is_cell_free(cell: Vector3) -> bool:
	return !is_cell_tile(cell) && get_damagable_on_cell(cell) == null


# Returns true is the given cell is one of the tile of one of the layers constiting the map
# Unless is_cell_ground this function will return true even if the tile isn't an accecible one
func is_cell_tile(cell: Vector3) ->  bool:
	var layer = get_layer(round(cell.z))
	return layer != null && layer.get_cell(cell.x, cell.y) != TileMap.INVALID_CELL


func is_cell_above_ground(cell: Vector3):
	return is_cell_ground(Vector3(cell.x, cell.y, round(cell.z - 1)))


# Return true if the given cell exists in the map's accesible tiles
func is_cell_ground(cell: Vector3) -> bool:
	return cell in grounds


# Find if the given world position can be found in the given cell
func is_world_pos_in_cell(pos: Vector2, cell: Vector3) -> bool:
	var cell_stack = get_cell_stack_at_pos(pos)
	for c in cell_stack:
		if c == cell:
			return true
	return false


# Check if a position is valid, return true if it is, false if it is not
func is_position_valid(cell: Vector3) -> bool:
	return !is_cell_in_obstacle(cell) && is_cell_ground(cell)



# Find if a cell x and y is in the heightmap grid, and returns it
# Return Vector3.INF if nothing was found
static func find_2D_cell(cell : Vector2, grid: PoolVector3Array) -> Vector3:
	for grid_cell in grid:
		if (cell.x == grid_cell.x) && (cell.y == grid_cell.y):
			return grid_cell
	return Vector3.INF


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


#### SIGNAL RESPONSES ####

func _on_iso_object_cell_changed(_iso_object: IsoObject):
	pass


func _on_iso_object_removed(iso_object: IsoObject):
	if !iso_object.is_passable():
		obstacles.erase(iso_object)
