tool
extends Control
class_name Gauge

# A class for gauge with basic feedbacks adding in-game context 
# (How many units are lost, shake with dynamic intensity based on the loss)

# You can change the duration of the gauge movement with loss_feedback_duration & gain_feedback_duration
# If shake_feedback_on is true, a shake feedback is added when the gauge just lost a large amount of value
# Useful for HP gauge for exemple

onready var tween_node = $Tween
onready var gauge : TextureProgress = $Gauge
onready var feedback_gauge : TextureProgress = $FeedbackGauge
onready var starting_position = rect_position

export var gauge_color : Color setget set_gauge_color
export var feedback_gauge_color : Color setget set_feedback_gauge_color

export var gauge_value : int = 100 setget set_gauge_value, get_gauge_value
export var gauge_max_value : int = 100 setget set_gauge_max_value, get_gauge_max_value

export var shake_feedback_on : bool = false

export var loss_feedback_duration : float = 0.6
export var gain_feedback_duration : float = 1.0

export var background_texture : Texture setget set_background_texture, get_background_texture
export var gauge_texture : Texture setget set_gauge_texture, get_gauge_texture

var is_ready : bool = false

#### ACCESSORS ####

func is_class(value: String): return value == "gauge" or .is_class(value)
func get_class() -> String: return "gauge"

func set_gauge_value(value: int, instantanious: bool = true):
	if !is_ready:
		yield(self, "ready")
	
	if instantanious:
		gauge.set_value(value)
		feedback_gauge.set_value(value)
	else:
		value_change_feedback(gauge_value, value)
	
	gauge_value = value

func get_gauge_value() -> int: return gauge_value

func set_gauge_max_value(value: int): 
	gauge_max_value = value
	gauge.set_max(gauge_max_value)
	feedback_gauge.set_max(gauge_max_value)

func get_gauge_max_value() -> int: return gauge_max_value

func set_gauge_color(value: Color):
	if !is_ready:
		yield(self, "ready")
	
	gauge_color = value
	gauge.set_tint_progress(value)

func set_feedback_gauge_color(value: Color):
	if !is_ready:
		yield(self, "ready")
	
	feedback_gauge_color = value
	feedback_gauge.set_tint_progress(value)

func set_background_texture(value: Texture):
	if !is_ready:
		yield(self, "ready")
	
	background_texture = value
	feedback_gauge.set_under_texture(value)

func get_background_texture() -> Texture: return background_texture

func set_gauge_texture(value: Texture):
	if !is_ready:
		yield(self, "ready")
		
	gauge_texture = value
	feedback_gauge.set_progress_texture(value)
	gauge.set_progress_texture(value)

func get_gauge_texture() -> Texture: return gauge_texture

#### BUILT-IN ####


func _ready() -> void:
	var __ = tween_node.connect("tween_completed", self, "_on_tween_completed")
	
	is_ready = true
	
	gauge.set_tint_progress(gauge_color)
	feedback_gauge.set_tint_progress(feedback_gauge_color)


#### VIRTUALS ####



#### LOGIC ####

func value_change_feedback(start_value: int, final_value: int):
	if final_value < 0.0 or final_value == start_value:
		return

	var change_amount = final_value - start_value
	var change_ratio = float(change_amount) / float(gauge_max_value)
	var value_lost : bool = change_ratio < 0
	
	# Loss feedback
	if value_lost && shake_feedback_on:
		var magnitude = abs(change_ratio) * 5
		shake(magnitude)
	
	# Gauge movement
	var duration = loss_feedback_duration if value_lost else gain_feedback_duration
	
	tween_node.interpolate_property(gauge, "value",
		start_value, final_value, duration, 
		Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	
	tween_node.start()


func shake(magnitude: float, duration : float = 0.25,
		 min_mov_nb: int = 4, mov_variance : int = 1):
	
	mov_variance = int(clamp(mov_variance, 1, INF))
	var nb_mov = randi() % mov_variance + min_mov_nb
	
	for i in nb_mov + 1:
		var rdm_angle = rand_range(0.0, 360.0)
		var dir = Vector2(cos(rdm_angle), sin(rdm_angle))
		var dest = starting_position + dir * magnitude if i != nb_mov else starting_position
		
		tween_node.interpolate_property(self, "rect_position",
			rect_position, dest, duration / (nb_mov + 1), 
			Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		
		tween_node.start()
		yield(tween_node, "tween_completed")



#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_tween_completed(obj: Object, _key: String):
	if obj == gauge:
		tween_node.interpolate_property(feedback_gauge, "value",
			feedback_gauge.get_value(), gauge.get_value(), 0.2, 
			Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		
		tween_node.start()
