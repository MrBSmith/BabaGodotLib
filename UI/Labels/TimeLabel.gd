tool
extends Label
class_name TimeLabel

# Expressed in seconds
var time : float  = 0.0 setget set_time

signal amount_tweening_finished

#### ACCESSORS ####

func is_class(value: String): return value == "TimeLabel" or .is_class(value)
func get_class() -> String: return "TimeLabel"

func set_time(value: float) -> void:
	time = value
	var time_formated = Utils.secs_to_formated_time(time, 1)
	set_text(time_formated)


#### BUILT-IN ####



#### VIRTUALS ####



#### LOGIC ####


func set_amount(amount: int) -> void:
	set_time(float(amount))


func tween_amount(new_amount: int, duration := 0.3) -> void:
	tween_time(float(new_amount), duration)


func tween_time(new_time: float, duration := 0.3) -> void:
	var tween = create_tween()
	
	var tweener = tween.tween_method(self, "set_time", time, new_time, duration)
	tweener.set_trans(Tween.TRANS_SINE)
	tweener.set_ease(Tween.EASE_IN_OUT)
	
	yield(tween, "finished")
	emit_signal("amount_tweening_finished")




#### INPUTS ####



#### SIGNAL RESPONSES ####
