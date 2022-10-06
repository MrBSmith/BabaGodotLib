tool
extends Node2D
class_name PulsingLight

onready var tween_node : Tween = $Tween
onready var timer_node : Timer = $Timer

export var pulse_duration : float = 0.5
export var pulse_delay : float = 0.3
export var light_color : Color = Color.white setget set_light_color, get_light_color
export var pulsing : bool = false setget set_pulsing, is_pulsing

onready var initial_scale = get_scale()
onready var current_color : Color = get_light_color() setget set_current_color, get_current_color
onready var initial_mask_text_scale : float = $LightMask.get_texture_scale()

signal pulsing_changed

#### ACCESSORS ####

func is_class(value: String): return value == "PulsingLight" or .is_class(value)
func get_class() -> String: return "PulsingLight"

func set_light_color(value: Color):
	light_color = value
	set_current_color(light_color)

func get_light_color() -> Color: return light_color

func set_current_color(value: Color):
	current_color = value
	$Light2D.set_color(current_color)
	$LightMask.set_color(current_color)

func get_current_color() -> Color: return current_color

func set_pulsing(value: bool): 
	if value != pulsing:
		pulsing = value
		emit_signal("pulsing_changed")
func is_pulsing() -> bool: return pulsing


#### BUILT-IN ####


func _init() -> void:
	var __ = connect("pulsing_changed", self, "_on_pulsing_changed")


func _ready() -> void:
	var __ = tween_node.connect("tween_all_completed", self, "_on_tween_all_completed")
	__ = timer_node.connect("timeout", self, "_on_timer_timeout")


#### VIRTUALS ####



#### LOGIC ####

func start_pulsing():
	var __ = tween_node.interpolate_property(self, "scale", Vector2.ZERO, initial_scale, 
						pulse_duration, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)

	__ = tween_node.interpolate_property($LightMask, "texture_scale", initial_mask_text_scale, 1.0, 
						pulse_duration, Tween.TRANS_SINE, Tween.EASE_IN)
	
	__ = tween_node.start()
	
	_fade()


func _fade(from : Color = light_color, to := Color.transparent, delay: float = pulse_duration / 2) -> void:
	var __ = tween_node.interpolate_method(self, "set_current_color", from, to,
						pulse_duration / 2, Tween.TRANS_CUBIC, Tween.EASE_IN, delay)
	
	__ = tween_node.start()



#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_tween_all_completed():
	timer_node.start(pulse_delay)


func _on_timer_timeout():
	if pulsing:
		start_pulsing()


func _on_pulsing_changed() -> void:
	if !is_inside_tree():
		yield(self, "ready")
	
	if pulsing:
		start_pulsing()
	else:
		_fade(get_current_color(), Color.transparent, 0.0)
