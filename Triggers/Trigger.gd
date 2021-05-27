extends Node2D
class_name Trigger

export var enabled : bool = true setget set_enabled, is_enabled

# warnings-disable
signal triggered()

#### ACCESSORS ####

func is_class(value: String): return value == "Trigger" or .is_class(value)
func get_class() -> String: return "Trigger"

func set_enabled(value: bool): enabled = value
func is_enabled() -> bool: return enabled

#### BUILT-IN ####



#### VIRTUALS ####



#### LOGIC ####

func trigger() -> void:
	if enabled:
		emit_signal("triggered")

#### INPUTS ####



#### SIGNAL RESPONSES ####
