tool
extends IsoTileMap
class_name IsoMapLayer

# A base class to represent a IsoMapLayer
# Also carry a tool that place walls below a tile automaticly

const print_log : bool = false

func _ready() -> void:
	var _err = EVENTS.connect("hide_iso_objects", self, "_on_hide_iso_objects_event")
	
	if !Engine.editor_hint:
		set_visible(false)


#### LOGIC ####

func _update_walls(tile: Vector2) -> void:
	var tile_id = get_cellv(tile)
	var tile_name = tile_set.tile_get_name(tile_id) if tile_id != -1 else ""
	var wall_tile_id = tile_set.find_tile_by_name(tile_name + "Wall")
	
	if wall_tile_id != -1 or tile_id == -1:
		var variation = randi() % 3
		
		for i in range(2):
			var current_wall_tilemap = $WestWall if i == 0 else $EastWall
			var dir = Vector2.DOWN if i == 0 else Vector2.RIGHT
			var has_neigbour = (tile + dir) in get_used_cells()
			var tile_to_place = -1 if has_neigbour else wall_tile_id
			var offset = 0 if i == 0 else 3
			var subtile_pos = Vector2(offset + variation, 0)
			
			current_wall_tilemap.set_cell(tile.x, tile.y, tile_to_place,
						false, false, false, subtile_pos)
			
			if print_log:
				if tile_to_place == -1:
					print("Added an empty wall at cell %s" % String(tile))
				elif current_wall_tilemap == $WestWall:
					print("Added a west wall a cell %s" % String(tile))
				elif current_wall_tilemap == $EastWall:
					print("Added a east wall a cell %s" % String(tile))
	else:
		if print_log:
			print_debug("No corresponding wall tile was found")


func _update_tile_neighbours(tile: Vector2) -> void:
	for i in range(4):
		var vertical = i % 2 == 0
		var dir_sign = int(i <= 1) * 2 - 1
		var dir = Vector2(int(!vertical), int(vertical)) * dir_sign
		
		if (tile + dir) in get_used_cells():
			_update_walls(tile + dir)


func clear():
	.clear()
	for child in get_children():
		child.clear()


#### INPUTS ####


#### SIGNAL RESPONSES ####


func _on_hide_iso_objects_event(hide: bool) -> void:
	set_visible(!hide)


func _on_tile_added(cell: Vector2) -> void:
	if print_log:
		print("Tile added a cell %s" % String(cell))
	
	yield(get_tree(), "idle_frame")
	
	_update_walls(cell)
	_update_tile_neighbours(cell)
	
	update_bitmask_area(cell)
	
	EVENTS.emit_signal("tile_added", self, Vector3(cell.x, cell.y, get_layer_id()))


func _on_tile_removed(cell: Vector2) -> void:
	if print_log:
		print("Tile removed a cell %s" % String(cell))
	
	yield(get_tree(), "idle_frame")
	
	for i in range(2):
		var current_wall_tilemap = $WestWall if i == 0 else $EastWall
		current_wall_tilemap.set_cell(cell.x, cell.y, -1,
			false, false, false, Vector2.ZERO)
	
	_update_tile_neighbours(cell)
	update_bitmask_area(cell)
	
	EVENTS.emit_signal("tile_removed", self, Vector3(cell.x, cell.y, get_layer_id()))


func _on_tile_replaced(cell: Vector2) -> void:
	_on_tile_removed(cell)
	_on_tile_added(cell)


func _on_tile_rect_added(rect: Rect2) -> void:
	for i in range(rect.size.y):
		for j in range(rect.size.x):
			var cell = Vector2(rect.position.x + j, rect.position.y + i)
			_update_walls(cell)
			_update_tile_neighbours(cell)
	
	._on_tile_rect_added(rect)


func _on_tile_rect_removed(rect: Rect2) -> void:
	for i in range(rect.size.y + 1):
		for j in range(rect.size.x + 1):
			var cell = Vector2(rect.position.x + j, rect.position.y + i)
			
			for k in range(2):
				var current_wall_tilemap = $WestWall if k == 0 else $EastWall
				current_wall_tilemap.set_cell(cell.x, cell.y, -1,
					false, false, false, Vector2.ZERO)
			
			_update_tile_neighbours(cell)
	
	._on_tile_rect_removed(rect)
