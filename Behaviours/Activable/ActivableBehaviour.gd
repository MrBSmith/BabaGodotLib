extends Behaviour
class_name ActivableBehaviour

export var active : bool = false setget set_active, is_active 

signal active_changed(active)

#### ACCESSORS ####

func is_class(value: String): return value == "ActivableBehaviour" or .is_class(value)
func get_class() -> String: return "ActivableBehaviour"

func set_active(value: bool) -> void:
	if value != active:
		active = value
		emit_signal("active_changed", active)
func is_active() -> bool: return active

#### BUILT-IN ####

func _ready() -> void:
	pass

#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####
