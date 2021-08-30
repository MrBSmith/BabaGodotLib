extends TileMap
class_name IsoTileMap

var render_parts = []

signal tile_added(cell)
signal tile_removed(cell)
signal tile_replaced(cell)

signal tile_rect_added(rect)
signal tile_rect_removed(rect)

#### ACCESSORS ####

func is_class(value: String): return value == "IsoTileMap" or .is_class(value)
func get_class() -> String: return "IsoTileMap"


#### BUILT-IN ####

func _ready() -> void:
	var __ = connect("tile_added", self , "_on_tile_added")
	__ = connect("tile_removed", self , "_on_tile_removed")
	__ = connect("tile_replaced", self , "_on_tile_replaced")
	__ = connect("tile_rect_added", self , "_on_tile_rect_added")
	__ = connect("tile_rect_removed", self , "_on_tile_rect_removed")


# Built-in funciton_overide
func set_cell(x: int, y: int, tile_id: int, flip_h: bool = false,  flip_v: bool = false,
			transpose: bool = false, subtile_pos:= Vector2.ZERO) -> void :
	
	var cell = Vector2(x, y)
	
	if tile_id == -1:
		if cell in get_used_cells():
			emit_signal("tile_removed", cell)
	else:
		if cell in get_used_cells():
			if get_cellv(cell) == tile_id:
				# The tile same tile is already in place
				return
			else:
				emit_signal("tile_replaced", cell)
		else:
			if tile_id in get_tileset().get_tiles_ids():
				emit_signal("tile_added", cell)
	
	.set_cell(x, y, tile_id, transpose, flip_h, flip_v, subtile_pos)


# Built-in funciton_overide
func set_cellv(cell: Vector2, tile_id: int, flip_h: bool = false,  flip_v: bool = false,
			transpose: bool = false, subtile_pos:= Vector2.ZERO) -> void :

	set_cell(int(cell.x), int(cell.y), tile_id, flip_h, flip_v, transpose, subtile_pos)


func set_rect_cell(rect: Rect2, tile_id: int, transpose: bool = false, 
					flip_h: bool = false, flip_v: bool = false) -> void:
	
	for i in range(rect.size.y + 1):
		for j in range(rect.size.x + 1):
			var cell = Vector2(rect.position.x + j, rect.position.y + i)
			.set_cellv(cell, tile_id, flip_h, flip_v, transpose)
	
	if tile_id == -1:
		emit_signal("tile_rect_removed", rect)
	else:
		emit_signal("tile_rect_added", rect)


func set_cell_array(tile_array: Array) -> void:
	var smallest_x = INF
	var smallest_y = INF
	var biggest_x = -INF
	var biggest_y = -INF
	
	for tile in tile_array:
		var cell = tile.cell
		
		if cell.x < smallest_x: smallest_x = cell.x
		if cell.y < smallest_y: smallest_y = cell.y
		if cell.x > biggest_x: biggest_x = cell.x
		if cell.y > biggest_y: biggest_y = cell.y
		
		.set_cellv(Utils.vec2_from_vec3(cell), tile.tile_id)
	
	emit_signal("tile_rect_added", (Rect2(Vector2(smallest_x, smallest_y), 
				Vector2(biggest_x - smallest_x + 1, biggest_y - smallest_y + 1))))


func update_bitmask_area(cell: Vector2) -> void:
	.update_bitmask_area(cell)
	
	EVENTS.emit_signal("autotile_region_updated", self, Vector3(cell.x, cell.y, get_layer_id()))


func clear():
	.clear()
	EVENTS.emit_signal("iso_tilemap_cleared", self)


#### VIRTUALS ####



#### LOGIC ####

func get_layer_id(layer: Node = self) -> int:
	var parent = get_parent()
	if parent.is_class("IsoMap"):
		return parent.get_layer_height(self)
	else:
		return parent.get_layer_id(layer)


#### INPUTS ####



#### SIGNAL RESPONSES ####


func _on_tile_added(cell: Vector2) -> void:
	if Engine.editor_hint:
		return
	
	yield(get_tree(), "idle_frame")
	EVENTS.emit_signal("tile_added", self, Vector3(cell.x, cell.y, get_layer_id()))


func _on_tile_removed(cell: Vector2) -> void:
	if Engine.editor_hint:
		return
	
	yield(get_tree(), "idle_frame")
	EVENTS.emit_signal("tile_removed", self, Vector3(cell.x, cell.y, get_layer_id()))


func _on_tile_replaced(cell: Vector2) -> void:
	_on_tile_removed(cell)
	_on_tile_added(cell)


func _on_tile_rect_added(rect: Rect2) -> void:
	yield(get_tree(), "idle_frame")
	update_bitmask_region(rect.position - Vector2.ONE, rect.position + rect.size + Vector2.ONE)
	
	EVENTS.emit_signal("rect_tile_added", self, rect, get_layer_id())


func _on_tile_rect_removed(rect: Rect2) -> void:
	yield(get_tree(), "idle_frame")
	update_bitmask_region(rect.position - Vector2.ONE, rect.position + rect.size + Vector2.ONE)
	
	EVENTS.emit_signal("rect_tile_removed", self, rect, get_layer_id())
