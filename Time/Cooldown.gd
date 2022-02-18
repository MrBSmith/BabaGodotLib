tool
extends Timer
class_name Cooldown

#### ACCESSORS ####

func is_class(value: String): return value == "Cooldown" or .is_class(value)
func get_class() -> String: return "Cooldown"


#### BUILT-IN ####

func _ready() -> void:
	autostart = false
	one_shot = true


#### VIRTUALS ####


#### LOGIC ####

func is_running() -> bool:
	return !is_paused() && !is_stopped()


#### INPUTS ####



#### SIGNAL RESPONSES ####
