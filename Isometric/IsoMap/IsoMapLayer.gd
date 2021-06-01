tool
extends TileMap
class_name IsoMapLayer

signal tile_added(tile)
signal tile_removed(tile)

# A base class to represent a IsoMapLayer

func _ready() -> void:
	var _err = EVENTS.connect("hide_iso_objects", self, "_on_hide_iso_objects_event")
	
	if !Engine.editor_hint:
		set_visible(false)
	
	var __ = connect("tile_added", self , "_on_tile_added")
	__ = connect("tile_removed", self , "_on_tile_removed")


# Built-in funciton_overide
func set_cell(x: int, y: int, tile_id: int, transpose: bool = false,
		 flip_h: bool = false,  flip_v: bool = false, 
		subtile_pos:= Vector2.ZERO) -> void :
	
	var cell = Vector2(x, y)
	
	if tile_id != -1:
		if tile_id in get_tileset().get_tiles_ids():
			emit_signal("tile_added", cell)
	else:
		if cell in get_used_cells():
			emit_signal("tile_removed", cell)
	
	.set_cell(x, y, tile_id, transpose, flip_h, flip_v, subtile_pos)


#### LOGIC ####

func _update_walls(tile: Vector2) -> void:
	var tileset = get_tileset()
	var tiles_id_array = tile_set.get_tiles_ids()
	
	var tile_id = get_cellv(tile)
	var tile_name = tileset.tile_get_name(tile_id)
	
	# Find the wall tile corresponding 
	var wall_tile_id = -1
	for current_tile_id in tiles_id_array:
		var current_tile_name = tileset.tile_get_name(current_tile_id)
		if current_tile_name == tile_name + "Wall":
			wall_tile_id = current_tile_id
			break
	
	if wall_tile_id != -1:
		var variation = randi() % 2
		
		for i in range(2):
			var current_wall_tilemap = $WestWall if i == 0 else $EastWall
			var dir = Vector2.DOWN if i == 0 else Vector2.RIGHT
			var has_neigbour = (tile + dir) in get_used_cells()
			var tile_to_place = -1 if has_neigbour else wall_tile_id
			var offset = 0 if i == 0 else 2
			var subtile_pos = Vector2(offset + variation, 0)
			
			current_wall_tilemap.set_cell(tile.x, tile.y, tile_to_place,
						false, false, false, subtile_pos)


#### INPUTS ####


#### SIGNAL RESPONSES ####

func _on_hide_iso_objects_event(hide: bool) -> void:
	set_visible(!hide)


func _on_tile_added(tile: Vector2) -> void:
	_update_walls(tile)
	
	yield(get_tree(), "idle_frame")
	
	# Update neighbours
	for i in range(4):
		var vertical = i % 2 == 0
		var dir_sign = int(i <= 1) * 2 - 1
		var dir = Vector2(int(!vertical), int(vertical)) * dir_sign
		
		if (tile + dir) in get_used_cells():
			_update_walls(tile + dir)


func _on_tile_removed(tile: Vector2) -> void:
	for i in range(2):
		var current_wall_tilemap = $WestWall if i == 0 else $EastWall
		current_wall_tilemap.set_cell(tile.x, tile.y, -1,
			false, false, false, Vector2.ZERO)
