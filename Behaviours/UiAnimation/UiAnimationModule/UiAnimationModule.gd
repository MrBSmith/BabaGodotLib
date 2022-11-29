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


@export_enum(TRANS_TYPE) var trans_type_in : int = TRANS_TYPE.TRANS_CUBIC
@export_enum(TRANS_TYPE) var trans_type_out : int = TRANS_TYPE.TRANS_CUBIC
@export_enum(EASE_TYPE) var ease_type_in : int = EASE_TYPE.EASE_IN_OUT
@export_enum(EASE_TYPE) var ease_type_out : int = EASE_TYPE.EASE_IN_OUT

@export var disabled : bool = false

@export var anim_duration : float = 1.0 # (float, 0.01, 999.0)

var target : Control : set = set_target
var animation_playing : bool = false : get = is_animation_playing, set = set_animation_playing

#warning-ignore:unused_signal
signal animation_finished
signal target_changed

#### ACCESSORS ####

func is_class(value: String): return value == "UIAnimationModule" or super.is_class(value)
func get_class() -> String: return "UIAnimationModule"

func set_animation_playing(value: bool): animation_playing = value
func is_animation_playing() -> bool: return animation_playing

func set_target(value: Control) -> void:
	if value != target:
		target = value
		emit_signal("target_changed")

#### BUILT-IN ####

func _ready() -> void:
	var __ = connect("target_changed",Callable(self,"_on_target_changed"))


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
