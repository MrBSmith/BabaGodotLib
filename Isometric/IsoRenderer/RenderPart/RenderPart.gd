extends Sprite
class_name RenderPart

var renderer

var sin_movement_dir : int = 0
var sin_nb_movements : int = 0
var sin_mov_magnitude : float = 0.0
var sin_mov_duration : float = 0.0
var sin_mov_origin := Vector2.ZERO

var altitude : int setget set_altitude, get_altitude

var current_cell : Vector3 setget set_current_cell, get_current_cell
var object_ref : Node = null setget set_object_ref, get_object_ref 

signal cell_changed(part, cell)

#### ACCESSORS ####

func is_class(value: String): return value == "RenderPart" or .is_class(value)
func get_class() -> String: return "RenderPart"

func set_current_cell(value: Vector3):
	if current_cell != value:
		current_cell = value
		emit_signal("cell_changed", self, current_cell)
func get_current_cell() -> Vector3: return current_cell

func set_object_ref(value: Node): object_ref = value
func get_object_ref() -> Node: return object_ref

func set_altitude(value: int): altitude = value
func get_altitude() -> int: return altitude


#### BUILT-IN ####



#### VIRTUALS ####



#### LOGIC ####

func destroy() -> void:
	if is_instance_valid(object_ref) && object_ref is IsoObject:
		object_ref.render_parts.erase(self)
	
	queue_free()

#### INPUTS ####



#### SIGNAL RESPONSES ####

