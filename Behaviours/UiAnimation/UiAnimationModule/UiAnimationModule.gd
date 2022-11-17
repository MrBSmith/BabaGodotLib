extends Node
class_name UIAnimationModule

enum TRANS_TYPE {
	TRANS_LINEAR = 0,
	TRANS_SINE = 1,
	TRANS_QUINT = 2,
	TRANS_QUART = 3,
	TRANS_QUAD = 4,
	TRANS_EXPO = 5,
	TRANS_ELASTIC = 6,
	TRANS_CUBIC = 7,
	TRANS_CIRC = 8,
	TRANS_BOUNCE = 9,
	TRANS_BACK = 10
}

enum EASE_TYPE {
	EASE_IN = 0,
	EASE_OUT = 1,
	EASE_IN_OUT = 2,
	EASE_OUT_IN = 3
}


export(TRANS_TYPE) var trans_type : int = TRANS_TYPE.TRANS_CUBIC
export(EASE_TYPE) var ease_type : int = EASE_TYPE.EASE_IN_OUT
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
