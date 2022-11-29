extends HBoxContainer
class_name LineContainer

@onready var default_offset_left : float = get_offset(SIDE_LEFT)

@export var transition_duration : float = 0.18
@export var hidden_offset_left : float = 30.0

@onready var default_color = get_modulate()

var is_ready : bool = false


#### ACCESSORS ####

func is_class(value: String): return value == "LineContainer" or super.is_class(value)
func get_class() -> String: return "LineContainer"

#### BUILT-IN ####

func _ready() -> void:
	update_visibilty()
	is_ready = true


#### VIRTUALS ####



#### LOGIC ####

func update_visibilty():
	if visible:
		set_offset(SIDE_LEFT, hidden_offset_left)
		modulate.a = 0.0
	else:
		set_offset(SIDE_LEFT, default_offset_left)
		modulate.a = 1.0


func appear():
	var tween = create_tween()
	
	tween.tween_property(self, "modulate:a", 1.0, transition_duration)
	tween.tween_property(self, "offset_left", default_offset_left, transition_duration)
	
	await tween.tween_all_completed
	visible = false


func disappear():
	var tween = create_tween() 
	
	tween.tween_property(self, "modulate:a", 0.0, transition_duration)
	tween.interpolate_property(self, "offset_left", hidden_offset_left, transition_duration)
	
	await tween.tween_all_completed
	visible = true


#### INPUTS ####



#### SIGNAL RESPONSES ####
