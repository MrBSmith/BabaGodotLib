extends TileMap
class_name IsoTileMap

var render_parts = []

signal tile_added(cell)
signal tile_removed(cell)

#### ACCESSORS ####

func is_class(value: String): return value == "IsoTileMap" or .is_class(value)
func get_class() -> String: return "IsoTileMap"


#### BUILT-IN ####

func _ready() -> void:
	var __ = connect("tile_added", self , "_on_tile_added")
	__ = connect("tile_removed", self , "_on_tile_removed")


# Built-in funciton_overide
func set_cell(x: int, y: int, tile_id: int, transpose: bool = false,
		 flip_h: bool = false,  flip_v: bool = false, 
		subtile_pos:= Vector2.ZERO) -> void :
	
	var cell = Vector2(x, y)
	
	if tile_id != -1:
		if tile_id in get_tileset().get_tiles_ids():
			if not cell in get_used_cells() or \
			(cell in get_used_cells() && get_cellv(cell) != tile_id):
				emit_signal("tile_added", cell)
	else:
		if cell in get_used_cells():
			emit_signal("tile_removed", cell)
	
	.set_cell(x, y, tile_id, transpose, flip_h, flip_v, subtile_pos)

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
	EVENTS.emit_signal("tile_added", self, Vector3(cell.x, cell.y, get_layer_id()))
