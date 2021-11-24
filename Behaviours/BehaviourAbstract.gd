extends Node2D
class_name Behaviour

export var behaviour_type: String = "" setget , get_behaviour_type

#### ACCESSORS ####

func is_class(value: String): return value == "Behaviour" or .is_class(value)
func get_class() -> String: return "Behaviour"

func get_behaviour_type() -> String: return behaviour_type

#### BUILT-IN ####

func _ready() -> void:
	yield(owner, "ready")
	
	owner.add_to_group(behaviour_type)


#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####
