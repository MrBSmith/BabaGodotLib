@tool
extends Control
class_name Gauge

# A class for gauge with basic feedbacks adding in-game context 
# (How many units are lost, shake with dynamic intensity based checked the loss)

# You can change the duration of the gauge movement with loss_feedback_duration & gain_feedback_duration
# If shake_feedback_on is true, a shake feedback is added when the gauge just lost a large amount of value
# Useful for HP gauge for exemple

@onready var gauge : TextureProgressBar = $Gauge
@onready var feedback_gauge : TextureProgressBar = $FeedbackGauge
@onready var starting_position = position

@export_group("Colors")
@export var gauge_color : Color:
	set(value):
		if !is_ready:
			await self.ready
	
		gauge_color = value
		gauge.set_tint_progress(value)
@export var feedback_gauge_color : Color:
	set(value):
		if !is_ready:
			await self.ready
		
		feedback_gauge_color = value
		feedback_gauge.set_tint_progress(value)

@export_group("Values")
@export var gauge_value : int = 100:
	set(value):
		if !is_ready:
			await self.ready
	
		if instantanious:
			gauge.set_value(value)
			feedback_gauge.set_value(value)
		else:
			value_change_feedback(gauge_value, value)
		
		gauge_value = value
@export var gauge_max_value : int = 100:
	set(value):
		if !is_ready:
			await self.ready
		
		gauge_max_value = value
		gauge.set_max(gauge_max_value)
		feedback_gauge.set_max(gauge_max_value)

@export_group("Feedback settings")
@export var shake_feedback_on : bool = false
@export var loss_feedback_duration : float = 0.6
@export var gain_feedback_duration : float = 1.0

@export_group("Textures")
@export var background_texture : Texture2D:
	set(value):
		if !is_ready:
			await self.ready
		
		background_texture = value
		feedback_gauge.set_under_texture(value)
@export var gauge_texture : Texture2D :
	set(value):
		if !is_ready:
			await self.ready
			
		gauge_texture = value
		feedback_gauge.set_progress_texture(value)
		gauge.set_progress_texture(value)

var instantanious : bool = false
var is_ready : bool = false

#### ACCESSORS ####

func is_class(value: String): return value == "gauge" or super.is_class(value)
func get_class() -> String: return "gauge"


#### BUILT-IN ####


func _ready() -> void:
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
		var magnitude = abs(change_ratio) * 4
		shake(magnitude)
	
	# Gauge movement
	var duration = loss_feedback_duration if value_lost else gain_feedback_duration
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	
	tween.tween_property(gauge, "value", final_value, duration)


func shake(magnitude: float, duration : float = 0.25, min_mov_nb: int = 4, mov_variance : int = 1):
	mov_variance = int(clamp(mov_variance, 1, INF))
	var nb_mov = randi() % mov_variance + min_mov_nb
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	
	for i in nb_mov + 1:
		var rdm_angle = randf_range(0.0, 360.0)
		var dir = Vector2(cos(rdm_angle), sin(rdm_angle))
		var dest = starting_position + dir * magnitude * scale if i != nb_mov else starting_position
		
		tween.tween_property(self, "position", dest, duration / (nb_mov + 1))



#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_tween_completed(obj: Object, _key: String):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	
	if obj == gauge:
		tween.tween_property(feedback_gauge, "value", gauge.get_value(), 0.2)
