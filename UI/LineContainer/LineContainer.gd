extends HBoxContainer
class_name LineContainer

onready var tween = $Tween

export var default_margin_left : float = 0

export var transition_duration : float = 0.2
export var hidden : bool = true setget set_hidden, is_hidden
export var hidden_margin_left : float = 30.0

var is_ready : bool = false


#### ACCESSORS ####

func is_class(value: String): return value == "LineContainer" or .is_class(value)
func get_class() -> String: return "LineContainer"

func set_hidden(value: bool):
	hidden = value
	update_visibilty()


func is_hidden() -> bool: return hidden


#### BUILT-IN ####

func _ready() -> void:
	update_visibilty()
	is_ready = true


#### VIRTUALS ####



#### LOGIC ####

func update_visibilty():
	if hidden:
		set_margin(MARGIN_LEFT, hidden_margin_left)
		set_modulate(Color.transparent)
	else:
		set_margin(MARGIN_LEFT, default_margin_left)
		set_modulate(Color.white)

func appear():
	tween.interpolate_property(self, "modulate",
		Color.transparent, Color.white, transition_duration,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	tween.interpolate_property(self, "margin_left",
		hidden_margin_left, default_margin_left, transition_duration,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	tween.start()
	
	yield(tween, "tween_all_completed")
	set_hidden(false)


func disappear():
	tween.interpolate_property(self, "modulate",
		Color.white, Color.transparent, transition_duration,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	tween.interpolate_property(self, "margin_left",
		default_margin_left, hidden_margin_left, transition_duration,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	tween.start()
	
	yield(tween, "tween_all_completed")
	set_hidden(true)


#### INPUTS ####



#### SIGNAL RESPONSES ####
