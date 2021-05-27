extends Trigger
class_name OnStartTrigger

#### ACCESSORS ####

func is_class(value: String): return value == "OnStartTrigger" or .is_class(value)
func get_class() -> String: return "OnStartTrigger"


#### BUILT-IN ####

func _ready() -> void:
	if owner.get("is_ready") != null && !owner.is_ready:
		yield(owner, "ready")
	
	trigger()

#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####
