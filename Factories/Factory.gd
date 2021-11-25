extends Node
class_name Factory

export var target_node : NodePath = ""
onready var target = owner.get_node(target_node) if String(target_node) != "" else get_tree().get_current_scene()

#### ACCESSORS ####

func is_class(value: String): return value == "Factory" or .is_class(value)
func get_class() -> String: return "Factory"


#### BUILT-IN ####



#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####
