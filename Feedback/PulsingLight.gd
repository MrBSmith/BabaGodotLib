@tool
extends Node2D
class_name PulsingLight

@onready var timer_node : Timer = $Timer

@export var pulse_duration : float = 0.5
@export var pulse_delay : float = 0.3
@export var light_color : Color = Color.WHITE : get = get_light_color, set = set_light_color
@export var pulsing : bool = false : get = is_pulsing, set = set_pulsing

@onready var initial_scale = get_scale()
@onready var current_color : Color = get_light_color() : get = get_current_color, set = set_current_color
@onready var initial_mask_text_scale : float = $LightMask.get_texture_scale()

signal pulsing_changed

#### ACCESSORS ####

func is_class(value: String): return value == "PulsingLight" or super.is_class(value)
func get_class() -> String: return "PulsingLight"

func set_light_color(value: Color):
	light_color = value
	set_current_color(light_color)

func get_light_color() -> Color: return light_color

func set_current_color(value: Color):
	current_color = value
	$PointLight2D.set_color(current_color)
	$LightMask.set_color(current_color)

func get_current_color() -> Color: return current_color

func set_pulsing(value: bool): 
	if value != pulsing:
		pulsing = value
		emit_signal("pulsing_changed")
func is_pulsing() -> bool: return pulsing


#### BUILT-IN ####


func _init():
	var __ = connect("pulsing_changed",Callable(self,"_on_pulsing_changed"))

#
#func _ready() -> void:
#	var __ = tween_node.connect("tween_all_completed",Callable(self,"_on_tween_all_completed"))
#	__ = timer_node.connect("timeout",Callable(self,"_on_timer_timeout"))


#### VIRTUALS ####



#### LOGIC ####

func start_pulsing():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(self, "scale", initial_scale, pulse_duration)
	tween.parallel().tween_property($LightMask, "texture_scale", 1.0, pulse_duration)
	
	tween.finished.connect("_on_tween_finished", CONNECT_ONE_SHOT)
	_fade()
	
	


func _fade(from : Color = light_color, to := Color.TRANSPARENT, delay: float = pulse_duration / 2) -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	
	tween.tween_method(set_current_color, from, to, pulse_duration / 2).set_delay(delay)



#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_tween_finished():
	timer_node.start(pulse_delay)


func _on_timer_timeout():
	if pulsing:
		start_pulsing()


func _on_pulsing_changed() -> void:
	if !is_inside_tree():
		await self.ready
	
	if pulsing:
		start_pulsing()
	else:
		_fade(get_current_color(), Color.TRANSPARENT, 0.0)
