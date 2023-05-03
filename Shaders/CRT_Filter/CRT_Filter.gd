tool
extends Node2D
class_name CRT_Filter

onready var aberation_mov_cooldown: Timer = $AberationMovCooldown
onready var chromatic_aberation: ColorRect = $CanvasLayer/ChromaticAberation

export(float, 0.0, 999.0) var aberation_amount : float = 0.5 setget set_aberation_amount
export(float, 0.0, 999.0) var movement_freq : float = 5.0
export(float, 0.0, 999.0) var movement_freq_variance : float = 2.0
export(float, 0.0, 999.0) var movement_amount : float = 2.0
export(float, 0.0, 999.0) var movement_amount_variance : float = 0.5
export(float, 0.0, 999.0) var movement_dur : float = 0.7
export(float, 0.0, 999.0) var movement_dur_variance : float = 0.3

signal animation_finished

#### ACCESSORS ####

func is_class(value: String): return value == "CRT_Filter" or .is_class(value)
func get_class() -> String: return "CRT_Filter"


func set_aberation_amount(value: float) -> void:
	if value != aberation_amount:
		aberation_amount = value
	
	if chromatic_aberation:
		chromatic_aberation.material.set_shader_param("aberation_amount", aberation_amount)


#### BUILT-IN ####

func _ready() -> void:
	if !Engine.editor_hint:
		_start_timer()
	
	EVENTS.connect("game_setting_changed", self, "_on_EVENTS_game_setting_changed")
	_update_epileptic_mode()


#### VIRTUALS ####



#### LOGIC ####

func _start_timer() -> void:
	if movement_freq > 0.0:
		var variance = rand_range(0.0, movement_freq_variance) * Math.rand_sign()
		aberation_mov_cooldown.start(movement_freq + variance)


func _aberation_animation() -> void:
	var dur_variance = rand_range(0.0, movement_dur_variance) * Math.rand_sign()
	var dur = movement_dur + dur_variance
	
	var amount_variance = rand_range(0.0, movement_amount_variance) * Math.rand_sign()
	var movement = (movement_amount + amount_variance) * Math.rand_sign()
	var dest = aberation_amount + movement
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(chromatic_aberation.material, "shader_param/aberation_amount", dest, dur / 2.0)
	tween.tween_property(chromatic_aberation.material, "shader_param/aberation_amount", aberation_amount, dur / 2.0)
	
	yield(tween, "finished")
	
	_start_timer()


func transition_animation(duration := 0.3, delay := 0.2, aberation := 30.0, displace := 30.0) -> void:
	aberation_mov_cooldown.stop()
	
	if delay > 0.0:
		yield(get_tree().create_timer(delay), "timeout")
	
	EVENTS.emit_signal("play_sound_effect", $GlitchSound)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_IN)
	
	tween.tween_property(chromatic_aberation.material, "shader_param/aberation_amount", aberation, duration)
	tween.parallel().tween_property(chromatic_aberation.material, "shader_param/displace_amount", int(displace), duration)
	
	yield(tween, "finished")
	emit_signal("animation_finished")


func _update_epileptic_mode() -> void:
	if Engine.editor_hint:
		return
	
	var epileptic_mode = SETTINGS.get_setting("epileptic_mode")
	$CanvasLayer.set_visible(!epileptic_mode)


#### INPUTS ####



#### SIGNAL RESPONSES ####


func _on_AberationMovCooldown_timeout() -> void:
	_aberation_animation()


func _on_EVENTS_game_setting_changed(_setting_name: String, _value) -> void:
	_update_epileptic_mode()


