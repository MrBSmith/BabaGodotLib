tool
extends Node2D
class_name IsoMap

# A base class to handle an iso IsoMap
# An iso IsoMap must be the parent of as many IsoMapLayer as your IsoMap has grounds (altitude levels)
 
const MAP_SEGMENT_SIZE = 6

enum SLOPE_TYPE {
	NONE,
	SLOPE_LEFT,
	SLOPE_RIGHT
}

onready var pathfinding = $Pathfinding
onready var cursor = $Interactives/Cursor

export var tileset : TileSet = null setget set_tileset, get_tileset

export var layer_scene_path : String = ""
onready var layer_scene = load(layer_scene_path)

var layers_array : Array setget , get_layers_array

var grounds := PoolVector3Array()
var walkable_cells : PoolVector3Array = []
var damagables : Array = [] setget set_damagables, get_damagables

var is_ready : bool = false

signal map_generation_finished

#### ACCESSORS ####

func is_class(value: String): return value == "IsoMap" or .is_class(value)
func get_class() -> String: return "IsoMap"

func set_damagables(array: Array):
	if array != damagables:
		damagables = array
		walkable_cells = pathfinding.set_walkable_cells(grounds)
		pathfinding.connect_walkable_cells(walkable_cells, owner.active_actor)
func get_damagables() -> Array: return damagables

func get_layers_array() -> Array: return layers_array

func get_tilemaps_recursive(array: Array, node: Node) -> void:
	for child in node.get_children():
		if child is TileMap && not child in array:
			array.append(child)
			if child.get_child_count() > 0:
				get_tilemaps_recursive(array, child)

func set_tileset(value: TileSet): 
	tileset = value
	for layer in layers_array:
		set_layer_tileset_recursive(layer)
func get_tileset() -> TileSet: return tileset

#### BUILT IN ####

func _ready():
	if Engine.editor_hint:
		return
	
	_fetch_layers()
	
	if get_layer(0) == null:
		add_layer(0)
	
	for layer in layers_array:
		set_layer_tileset_recursive(layer)
	
	_fetch_ground()
	_init_object_grid_pos()
	_fetch_damagables()
	
	var _err = EVENTS.connect("iso_object_cell_changed", self, "_on_iso_object_cell_changed")
	_err = EVENTS.connect("cursor_world_pos_changed", self, "_on_cursor_world_pos_changed")
	_err = EVENTS.connect("iso_object_removed", self, "_on_iso_object_removed")
	
	# Store all the passable cells into the array walkable_cells_list, 
	# by checking all the cells in the IsoMap to see if they are not an obstacle
	walkable_cells = pathfinding.set_walkable_cells(grounds)
	
	
	if owner != null:
		var active_actor = owner.get("active_actor")
	
		# Create the connections between all the walkable cells
		if is_instance_valid(active_actor):
			pathfinding.connect_walkable_cells(walkable_cells, active_actor)
	
	for obj in get_tree().get_nodes_in_group("IsoObject"):
		obj.map = self
	
	is_ready = true
	emit_signal("map_generation_finished")


#### LOGIC ####

# Get every unpassable object form the IsoObject group 
func _fetch_damagables() -> void:
	var iso_object_array = get_tree().get_nodes_in_group("IsoObject")
	var unpassable_objects : Array = []
	for object in iso_object_array:
		if !object.is_passable():
			unpassable_objects.append(object)
	
	set_damagables(unpassable_objects)


# Fetch every accessible cells and store it in grounds
func _fetch_ground() -> void:
	var feed_array : PoolVector3Array = []
	for i in range(layers_array.size() - 1, -1, -1):
		var current_layer = layers_array[i]
		var walls_tilemap = current_layer.get_node("Walls")
		var walls_cells = walls_tilemap.get_used_cells()
		
		for cell2d in current_layer.get_used_cells():
			if IsoLogic.find_2D_cell(Vector2(cell2d.x, cell2d.y), feed_array) == Vector3.INF:
				var current_cell = Vector3(cell2d.x, cell2d.y, i)
				
				if not cell2d in walls_cells:
					if get_cell_slope_type(cell2d, i) != 0:
						current_cell -= Vector3(0, 0, 0.5)
					feed_array.append(current_cell)
	
	# Handle bridges
	for i in range(layers_array.size()):
		for child in layers_array[i].get_children():
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


func _fetch_layers() -> void:
	for child in get_children():
		if child is IsoMapLayer:
			layers_array.append(child)


# Give every actor, his default grid pos
func _init_object_grid_pos():
	for object in get_tree().get_nodes_in_group("IsoObject"):
		var cell = get_pos_highest_cell(object.position)
		if cell == Vector3.INF:
			cell = Vector3.ZERO
		object.set_current_cell(cell)


#### LAYERS ####

func get_map_rect() -> Rect2:
	var layer_0 = get_layer(0)
	return layer_0.get_used_rect()


func add_layer(height: float) -> void:
	if get_layer(height) != null:
		return
	
	var highest_layer_z = get_highest_layer_z()
	var nb_layers_to_add = height - highest_layer_z
	
	for i in range(nb_layers_to_add):
		var layer = layer_scene.instance(PackedScene.GEN_EDIT_STATE_INSTANCE)
		layers_array.insert(int(round(height)), layer)
		call_deferred("add_child", layer)
		layer.call_deferred("set_owner", self)
		var layer_pos = Vector2.UP * (highest_layer_z + i + 1) * GAME.TILE_SIZE 
		layer.set_position(layer_pos)
		call_deferred("set_layer_tileset_recursive", layer)


func get_highest_layer_z() -> int:
	return layers_array.size() - 1 


# Return the layer at the given height
func get_layer(height: float) -> IsoMapLayer:
	if height >= layers_array.size() or height < 0:
		return null
	else:
		return layers_array[round(height)]


# Return the id of the layer at the given height
func get_layer_id(height: float) -> int:
	return get_layer(round(height)).get_index()


func get_layer_height(layer: IsoMapLayer) -> int:
	for i in range(layers_array.size()):
		if layers_array[i] == layer:
			return i
	return -1


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
	return layers_array[0].world_to_map(pos) + Vector2.ONE * layer_id

# Return the actor or obstacle placed on the given cell
# Works also if the cell is one of the cell the body of the object is in
# Return null if the cell is empty
func get_damagable_on_cell(cell: Vector3) -> Object:
	var damagable_array = get_tree().get_nodes_in_group("IsoObject")
	
	for object in damagable_array:
		if not object.is_class("TRPG_DamagableObject"):
			continue
		
		if object.is_dead():
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
		var cell = IsoLogic.find_2D_cell(point, grounds)
		if cell != Vector3.INF:
			cell_array.append(cell)
	
	return cell_array


# Take a cell and return its world position
func cell_to_world(cell: Vector3) -> Vector2:
	var pos = layers_array[0].map_to_world(Vector2(cell.x, cell.y))
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


func cell_2D_to_3D(cell: Vector2) -> Vector3:
	var z = get_cell2D_highest_z(cell)
	if z == -1.0: return Vector3.INF
	return Vector3(cell.x, cell.y, z)


# Returns the slope type of the given cell2D in the given layer
func get_cell_slope_type(cell2D: Vector2, layer_id: int) -> int:
	var layer : IsoMapLayer = get_layer(layer_id)
	if layer == null:
		return SLOPE_TYPE.NONE
	
	var layer_tileset : TileSet = layer.get_tileset()
	var tile_id : int = layer.get_cellv(cell2D)
	
	if layer_tileset == null or !(tile_id in layer_tileset.get_tiles_ids()):
		return SLOPE_TYPE.NONE
	
	var tile_name = layer_tileset.tile_get_name(tile_id)
		
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
func is_damagable_on_cell(cell: Vector3) -> bool:
	for obj in damagables:
		if cell == obj.get_current_cell():
			return true
	return false


# Check if the given cell is occupied by an obstacle 
# (ie a tile of the obstacle tilmap, child of a layer)
func is_occupied_by_obstacle(cell: Vector3) -> bool:
	for i in range(layers_array.size()):
		var layer = layers_array[i]
		var cell2d = Vector2(cell.x, cell.y)
		var obstacle_tilemap = layer.get_node("Obstacles")
		var tile_id = obstacle_tilemap.get_cellv(cell2d)
		
		if tile_id == -1:
			continue
		
		var cell_size = obstacle_tilemap.get_cell_size()
		var layer_tileset = obstacle_tilemap.get_tileset()
		var tile_mode = tileset.tile_get_tile_mode(tile_id)
		var tile_size = Vector2.ZERO
		
		if tile_mode == TileSet.SINGLE_TILE:
			tile_size = layer_tileset.tile_get_region(tile_id).size
		else:
			tile_size = layer_tileset.autotile_get_size(tile_id)
		
		var obst_height = round(tile_size.y / cell_size.y)
		if i + obst_height > cell.z && i <= cell.z:
			return true
	return false


# Return the highest cell in the grid at the given world position
# Can optionaly find it, starting from a given layer (To ignore higher layers)
func get_pos_highest_cell(pos: Vector2, max_layer: int = 0) -> Vector3:
	var ground_0_cell_2D = layers_array[0].world_to_map(pos)
	
	var nb_grounds = layers_array.size()
	if max_layer == 0 or max_layer > nb_grounds:
		max_layer = nb_grounds
		
	for i in range(max_layer - 1, -1, -1):
		var current_cell_2D = ground_0_cell_2D + Vector2(i, i)
		var current_cell_3D = Vector3(current_cell_2D.x, current_cell_2D.y, i)
		
		if get_cell_slope_type(current_cell_2D, i) != 0:
			current_cell_3D -= Vector3(0, 0, 0.5)
		
		if get_layer(i).get_cellv(current_cell_2D) != -1:
			return current_cell_3D
		
	return Vector3.INF


# Check if the cell is empty (ie there is no tile nor obstacle on it)
func is_cell_free(cell: Vector3) -> bool:
	return !is_cell_tile(cell) && !is_cell_wall(cell) && get_damagable_on_cell(cell) == null && !is_occupied_by_obstacle(cell)


func has_2D_cell(cell: Vector2) -> bool:
	for layer in get_layers_array():
		if layer.get_cellv(cell) != TileMap.INVALID_CELL:
			return true
	return false

# Returns true is the given cell is one of the tile of one of the layers constiting the map
# Unless is_cell_ground this function will return true even if the tile isn't an accecible one
func is_cell_tile(cell: Vector3) ->  bool:
	var layer = get_layer(round(cell.z))
	return layer != null && layer.get_cell(cell.x, cell.y) != TileMap.INVALID_CELL


func is_cell_wall(cell: Vector3) -> bool:
	var layer = get_layer(round(cell.z))
	return layer != null && layer.get_node("Walls").get_cell(cell.x, cell.y) != TileMap.INVALID_CELL


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
	return !is_damagable_on_cell(cell) && is_cell_ground(cell)


# Get the adjacent cells of the given one
func get_existing_adjacent_cells(cell: Vector3) -> PoolVector3Array:
	var adjacents : PoolVector3Array = []
	var relatives = IsoLogic.get_adjacent_cells(Vector2(cell.x, cell.y))
	
	for relative_cell in relatives:
		var adj = IsoLogic.find_2D_cell(relative_cell, grounds)
		if adj != Vector3.INF:
			adjacents.append(adj)
	
	return adjacents


func get_cells_in_range(origin: Vector3, dist_range: int) -> PoolVector3Array:
	var cells_at_dist = IsoLogic.get_cells_in_circle(origin, dist_range)
	var cells_in_range = PoolVector3Array()
	
	for cell in cells_at_dist:
		var z = get_cell2D_highest_z(Vector2(cell.x, cell.y))
		cells_in_range.append(Vector3(cell.x, cell.y, z))
	
	return cells_in_range


func get_nb_segments() -> Vector2:
	var map_rect = get_map_rect()
	var map_size = map_rect.size
	
	return Math.clamp_v((map_size / MAP_SEGMENT_SIZE).round(), Vector2.ONE, Vector2.INF)


func segment_get_pos(segment_id: int) -> Vector2:
	var map_size = get_nb_segments()
	var segment_col = segment_id % int(map_size.x) if segment_id != 0 else 0
	var segment_line = int(float(segment_id) / map_size.y) if segment_id != 0 else 0
	var segment_map_pos = Vector2(segment_col, segment_line)
	
	return segment_map_pos


func segment_get_origin(segment_id: int) -> Vector2:
	var map_rect = get_map_rect()
	return map_rect.position + segment_get_pos(segment_id) * MAP_SEGMENT_SIZE


func segment_get_rect(segment_id: int) -> Rect2:
	return Rect2(segment_get_origin(segment_id), Vector2.ONE * MAP_SEGMENT_SIZE)


func segment_get_nb_tiles(segment_id: int) -> int:
	var origin = segment_get_origin(segment_id)
	var nb_tiles = 0
	
	for i in range(MAP_SEGMENT_SIZE):
		for j in range(MAP_SEGMENT_SIZE):
			var cell = origin + Vector2(j, i)
			if has_2D_cell(cell):
				nb_tiles += 1
	return nb_tiles


func segment_get_center(segment_id: int) -> Vector3:
	var origin = segment_get_origin(segment_id)
	var center = origin + ((Vector2.ONE * MAP_SEGMENT_SIZE) / 2).round()
	
	var i = 0
	while(!has_2D_cell(center)):
		center = origin + Vector2(wrapi(i, 0, MAP_SEGMENT_SIZE), int(i / MAP_SEGMENT_SIZE))  
		i += 1
	
	return IsoLogic.find_2D_cell(center, walkable_cells)


func cell_get_segment(cell: Vector3) -> int:
	var cell_2D = Vector2(cell.x, cell.y)
	var nb_segments = get_nb_segments()
	
	for i in range(nb_segments.x * nb_segments.y):
		var segment_rect = segment_get_rect(i)
		if segment_rect.has_point(cell_2D):
			return i
	return -1


func get_segment_id(segment_pos: Vector2) -> int:
	return int(segment_pos.y) * int(get_nb_segments().x) + int(segment_pos.x)


func segment_exists(segment_id: int) -> bool:
	return segment_get_nb_tiles(segment_id) > 0


func segment_exists_v(seg_pos: Vector2) -> bool:
	var nb_seg_v = get_nb_segments()
	var nb_seg_rect = Rect2(Vector2.ZERO, nb_seg_v)
	
	return nb_seg_rect.has_point(seg_pos)


func get_same_adjacent_tiles(cell: Vector3, tile_id: int, array: Array) -> void:
	var adj_array = IsoLogic.get_v3_adjacent_cells(cell)
	
	for adj_cell in adj_array:
		if adj_cell in array:
			continue
		
		var layer = get_layer(adj_cell.z)
		var id = layer.get_cellv(Utils.vec2_from_vec3(adj_cell))
		
		if id == tile_id:
			array.append(adj_cell)
			get_same_adjacent_tiles(adj_cell, tile_id, array)


# Retruns a PoolVector3Array that contains the path to move towards a cell as much as possible
func find_approch_cell_path(actor: TRPG_Actor, cell: Vector3, max_movement : int = -1) -> PoolVector3Array:
	var actor_cell = actor.get_current_cell()
	var actor_movement = actor.get_current_movements() if max_movement == -1 else max_movement
	
	var path_to_reach = pathfinding.find_path_to_reach(actor_cell, cell)
	
	if max_movement != -1:
		path_to_reach.resize(int(clamp(actor_movement + 1, 0, path_to_reach.size())))
	
	return path_to_reach


func set_layer_tileset_recursive(node: TileMap) -> void:
	if node.get_tileset() == null:
		node.set_tileset(tileset)
		
	for child in node.get_children():
		if child is TileMap:
			set_layer_tileset_recursive(child)


#### SIGNAL RESPONSES ####

func _on_iso_object_cell_changed(_iso_object: IsoObject):
	pass


func _on_iso_object_removed(iso_object: IsoObject):
	if !iso_object.is_passable():
		damagables.erase(iso_object)
