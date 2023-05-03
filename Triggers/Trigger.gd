extends Node2D
class_name Trigger

export var enabled : bool = true setget set_enabled, is_enabled
export var trigger_on_level_started : bool = false

# warnings-disable
signal triggered()

#### ACCESSORS ####

func is_class(value: String): return value == "Trigger" or .is_class(value)
func get_class() -> String: return "Trigger"

func set_enabled(value: bool): enabled = value
func is_enabled() -> bool: return enabled

#### BUILT-IN ####

func _ready() -> void:
	if trigger_on_level_started:
		yield(EVENTS, "level_ready")
		
		VIEW_MANAGER.level.connect("level_started", self, "_on_level_started")

#### VIRTUALS ####



#### LOGIC ####

func trigger() -> void:
	if enabled && !is_queued_for_deletion():
		emit_signal("triggered")

#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_level_started() -> void:
	trigger()
