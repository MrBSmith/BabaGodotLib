tool
extends Label
class_name CounterLabel

onready var increment_sound = get_node_or_null("IncrementSound")
export var amount : int = 0 setget set_amount 

signal text_changed(text)
signal amount_changed(previous_amount, amount)
signal amount_tweening_finished()

#### ACCESSORS ####

func is_class(value: String): return value == "CounterLabel" or .is_class(value)
func get_class() -> String: return "CounterLabel"

func set_amount(value: int) -> void:
	if amount != value:
		var previous_amount = amount
		amount = value
		emit_signal("amount_changed", previous_amount, amount)

#### BUILT-IN ####

func _init() -> void:
	var __ = connect("amount_changed", self, "_on_amount_changed")



#### VIRTUALS ####



#### LOGIC ####

func tween_amount(new_amount: int, duration: float = 0.3, 
				trans_type: int = Tween.TRANS_LINEAR, 
				ease_type: int = Tween.EASE_IN) -> void:
	
	var tween = create_tween()
	
	var tweener = tween.tween_method(self, "set_amount", amount, new_amount, duration)
	tweener.set_trans(trans_type)
	tweener.set_ease(ease_type)
	
	yield(tween, "finished")
	emit_signal("amount_tweening_finished")


#### INPUTS ####



#### SIGNAL RESPONSES ####


func _on_amount_changed(previous_amount: int, new_amount: int) -> void:
	set_visible(amount != INF)
	set_text(str(amount))
	
	emit_signal("text_changed", text)
	
	if new_amount > previous_amount:
		if increment_sound:
			increment_sound.play()


