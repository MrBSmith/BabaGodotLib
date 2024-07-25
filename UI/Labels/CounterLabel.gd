tool
extends Label
class_name CounterLabel

onready var increment_sound = get_node_or_null("IncrementSound")
export var amount : int = 0 setget set_amount
var target_amount := 0

signal text_changed(text)
signal amount_changed(previous_amount, amount)
signal amount_tweening_finished()

var tween : SceneTreeTween

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

func reset(default_value: int = 0) -> void:
	if tween: tween.kill()
	set_amount(default_value)


func tween_amount(new_amount: int, duration: float = 0.3, 
				trans_type: int = Tween.TRANS_LINEAR, 
				ease_type: int = Tween.EASE_IN) -> void:
	
	if tween:
		tween.kill()
	
	target_amount = new_amount
	
	tween = create_tween()
	var __ = tween.connect("finished", self, "_on_tween_finished")
	
	var tweener = tween.tween_method(self, "set_amount", amount, new_amount, duration)
	tweener.set_trans(trans_type)
	tweener.set_ease(ease_type)



#### INPUTS ####



#### SIGNAL RESPONSES ####


func _on_amount_changed(previous_amount: int, new_amount: int) -> void:
	set_visible(amount != INF)
	set_text(str(amount))
	
	emit_signal("text_changed", text)
	
	if new_amount > previous_amount:
		if increment_sound:
			increment_sound.play()


func _on_tween_finished() -> void:
	emit_signal("amount_tweening_finished")
