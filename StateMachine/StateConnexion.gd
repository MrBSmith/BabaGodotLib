extends Node
class_name StateConnexion

var target_state_path := NodePath() 
var conditions_array = []


#### ACCESSORS ####

func is_class(value: String): return value == "StateConnexion" or .is_class(value)
func get_class() -> String: return "StateConnexion"


#### BUILT-IN ####

func _init(target: NodePath, cond_array :=  Array()) -> void:
	target_state_path = target
	conditions_array = cond_array


#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####
