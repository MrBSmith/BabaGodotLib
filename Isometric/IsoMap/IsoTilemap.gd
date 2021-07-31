extends TileMap
class_name IsoTileMap

var render_parts = []

signal tile_added(cell)
signal tile_removed(cell)
signal tile_replaced(cell)

#### ACCESSORS ####

func is_class(value: String): return value == "IsoTileMap" or .is_class(value)
func get_class() -> String: return "IsoTileMap"


#### BUILT-IN ####

func _ready() -> void:
	var __ = connect("tile_added", self , "_on_tile_added")
	__ = connect("tile_removed", self , "_on_tile_removed")
	__ = connect("tile_replaced", self , "_on_tile_replaced")


# Built-in funciton_overide
func set_cell(x: int, y: int, tile_id: int, transpose: bool = false,
		 flip_h: bool = false,  flip_v: bool = false, 
		subtile_pos:= Vector2.ZERO) -> void :
	
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
func set_cellv(cell: Vector2, tile_id: int, flip_h: bool = false, 
		flip_v: bool = false, transpose: bool = false):

	set_cell(int(cell.x), int(cell.y), tile_id, transpose, flip_h, flip_v)


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
	_on_tile_added(cell)
	_on_tile_removed(cell)
