extends Node2D
class_name IsoObject

enum VISIBILITY {
	VISIBLE,
	BARELY_VISIBLE,
	NOT_VISIBLE,
	HIDDEN
}

const COLOR_SCHEME = {
	VISIBILITY.VISIBLE : Color.white,
	VISIBILITY.BARELY_VISIBLE: Color.lightgray,
	VISIBILITY.NOT_VISIBLE: Color.darkgray,
	VISIBILITY.HIDDEN : Color.transparent
}

var current_cell := Vector3.INF setget set_current_cell, get_current_cell

var is_ready : bool = false
var visibility : int = VISIBILITY.VISIBLE setget set_visibility, get_visibility

export var always_visible : bool = false setget set_always_visible, is_always_visible
export var height : int = 1 setget set_height, get_height
export var passable : bool = true setget set_passable, is_passable

signal modulate_changed(mod)
signal cell_changed(cell)
signal global_position_changed(world_pos)

#### ACCESSORS ####

func set_current_cell(value: Vector3):
	var value_changed : bool = value != current_cell
	current_cell = value
	if value_changed && is_ready:
		EVENTS.emit_signal("iso_object_cell_changed", self)
		emit_signal("cell_changed", current_cell)

func get_current_cell() -> Vector3: return current_cell

func set_height(value : int):
	var value_changed : bool = value != height
	height = value
	if value_changed && is_ready:
		EVENTS.emit_signal("iso_object_cell_changed", self)

func get_height() -> int: return height

func set_passable(value : bool): passable = value
func is_passable() -> bool: return passable

func set_visibility(value: int):
	if always_visible && not value in [VISIBILITY.VISIBLE, VISIBILITY.HIDDEN]:
		return
	
	if value != visibility:
		visibility = value
		set_modulate(COLOR_SCHEME[visibility])

func get_visibility() -> int: return visibility

func set_always_visible(value: bool): always_visible = value
func is_always_visible() -> bool: return always_visible

func set_global_position(value):
	if value != global_position:
		global_position = value
		emit_signal("global_position_changed", value)

func set_modulate(value: Color):
	if value != get_modulate():
		modulate = value
		emit_signal("modulate_changed", modulate)

func is_in_view_field() -> bool:
	return get_visibility() in [VISIBILITY.VISIBLE, VISIBILITY.BARELY_VISIBLE]


#### BUILT-IN ####

func _ready():
	add_to_group("IsoObject")
	create()
	
	is_ready = true


#### LOGIC ####


func create():
	EVENTS.emit_signal("iso_object_added", self)


func destroy():
	if is_in_group("IsoObject"):
		remove_from_group("IsoObject")
	EVENTS.emit_signal("iso_object_removed", self)
	queue_free()
