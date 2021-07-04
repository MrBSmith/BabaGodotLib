extends Node2D
class_name IsoObject

# A base class every iso object should inherit from
# Handles the object visibility and cell position on the map

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

var render_parts := Array() 

var map = null
onready var tween : Tween = get_node_or_null("Tween")

var current_cell := Vector3.INF setget set_current_cell, get_current_cell

var is_ready : bool = false
var visibility : int = VISIBILITY.VISIBLE setget set_visibility, get_visibility
var targeted : bool = false setget ,is_targeted
var last_target_positive : bool = false

export var always_visible : bool = false setget set_always_visible, is_always_visible
export var height : int = 1 setget set_height, get_height
export var passable : bool = true setget set_passable, is_passable

signal modulate_changed(mod)
signal cell_changed(cell)
signal global_position_changed(world_pos)
signal targeted_feedback_loop_ended()
signal destroy_animation_finished()

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
	modulate = value
	emit_signal("modulate_changed", modulate)

func is_in_view_field() -> bool:
	return get_visibility() in [VISIBILITY.VISIBLE, VISIBILITY.BARELY_VISIBLE]


func set_targeted(value: bool, positive: bool = false):
	targeted = value
	if targeted:
		trigger_targeted_feedback(positive)
	else:
		var __ = tween.remove_all()
		set_modulate(COLOR_SCHEME[visibility])

func is_targeted() -> bool: return targeted


#### BUILT-IN ####

func _ready():
	var _err = EVENTS.connect("hide_iso_objects", self, "_on_hide_iso_objects_event")
	_err = connect("targeted_feedback_loop_ended", self, "_on_targeted_feedback_loop_ended")
	add_to_group("IsoObject")
	create()
	
	set_sprites_visible_recursive(false, self)
	is_ready = true


#### LOGIC ####

# Alias for set_modulate, usefull because Godot won't call overriden 
# set_modulate when calling some internal method
func change_modulate_color(color: Color):
	set_modulate(color)


func create():
	EVENTS.emit_signal("iso_object_added", self)


func destroy():
	if is_in_group("IsoObject"):
		remove_from_group("IsoObject")
	
	EVENTS.emit_signal("iso_object_removed", self)
	
	if has_signal("action_consequence_finished"): 
		emit_signal("action_consequence_finished")
	
	yield(self, "destroy_animation_finished")
	
	# Queue free this node only if the IsoObject doesn't have a state machines, 
	# meaning it can't have a dead state
	if !is_class("TRPG_Actor"):
		queue_free()


func trigger_destroy_animation() -> void:
	emit_signal("destroy_animation_finished")


func trigger_targeted_feedback(positive: bool = false):
	var target_color = Color.blue if !positive else Color.green
	last_target_positive = positive
	
	for i in range(2):
		var start_color = COLOR_SCHEME[visibility] if i == 0 else target_color
		var dest_color = target_color if i == 0 else COLOR_SCHEME[visibility]
		
		var __ = tween.interpolate_method(self, "set_modulate", start_color, dest_color, 
			0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		
		__ = tween.start()
		
		yield(tween, "tween_all_completed")
	
	emit_signal("targeted_feedback_loop_ended")


func set_sprites_visible_recursive(value: bool, node: Node) -> void:
	for child in node.get_children():
		if child.is_class("IsoSprite") or child.is_class("IsoAnimatedSprite"):
			child.set_visible(value)
		
		set_sprites_visible_recursive(value, child)

#### SIGNAL RESPONSES ####

func _on_hide_iso_objects_event(hide: bool):
	set_sprites_visible_recursive(!hide, self)


func _on_targeted_feedback_loop_ended():
	if targeted:
		trigger_targeted_feedback(last_target_positive) 
