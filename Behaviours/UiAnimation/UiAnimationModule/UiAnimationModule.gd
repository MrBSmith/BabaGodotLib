extends Node
class_name UIAnimationModule

export var disabled : bool = false

export(float, 0.01, 999.0) var anim_duration : float = 1.0

var target : Control setget set_target
var animation_playing : bool = false setget set_animation_playing, is_animation_playing

#warning-ignore:unused_signal
signal animation_finished
signal target_changed

#### ACCESSORS ####

func is_class(value: String): return value == "UIAnimationModule" or .is_class(value)
func get_class() -> String: return "UIAnimationModule"

func set_animation_playing(value: bool): animation_playing = value
func is_animation_playing() -> bool: return animation_playing

func set_target(value: Control) -> void:
	if value != target:
		target = value
		emit_signal("target_changed")

#### BUILT-IN ####

func _ready() -> void:
	var __ = connect("target_changed", self, "_on_target_changed")


#### VIRTUALS ####

func play() -> void:
	if animation_playing:
		push_error("The animation is already being played")
		return



#### LOGIC ####


#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_target_changed() -> void:
	pass
