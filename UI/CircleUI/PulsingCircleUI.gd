tool
extends CircleUI
class_name PulsingCircleUI

export var pulse_duration : float = 0.5
export var fade_delay : float = 0.3
export var fade_duration: float = 0.1
export var pulsing : bool = true setget set_pulsing

signal pulsing_changed

#### ACCESSORS ####

func is_class(value: String): return value == "PulsingCircleUI" or .is_class(value)
func get_class() -> String: return "PulsingCircleUI"


func set_pulsing(value: bool) -> void:
	if value != pulsing:
		pulsing = value
		emit_signal("pulsing_changed")


#### BUILT-IN ####

func _ready() -> void:
	if !Engine.editor_hint:
		set_scale(Vector2.ZERO)
		
		var __ = connect("pulsing_changed", self, "_on_pulsing_changed")
		_on_pulsing_changed()



#### VIRTUALS ####



#### LOGIC ####

func pulse() -> void:
	var scale_tween = create_tween()
	scale = Vector2.ZERO
	self_modulate = Color.white
	
	scale_tween.tween_property(self, "scale", Vector2.ONE, pulse_duration)
	scale_tween.set_trans(Tween.TRANS_CUBIC)
	
	yield(get_tree().create_timer(fade_delay), "timeout")
	
	var color_tween = create_tween()
	color_tween.tween_property(self, "self_modulate", Color.transparent, fade_duration)
	color_tween.set_trans(Tween.TRANS_CUBIC)
	



#### INPUTS ####



#### SIGNAL RESPONSES ####


func _on_Timer_timeout() -> void:
	pulse()


func _on_pulsing_changed() -> void:
	if pulsing:
		$Timer.start()
	else:
		$Timer.stop()
		set_scale(Vector2.ZERO)
