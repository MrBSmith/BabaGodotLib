tool
extends State
class_name ActorActionState

export var animated_sprite_path : NodePath
onready var animated_sprite = get_node(animated_sprite_path)

#### ACCESSORS ####

func is_class(value: String): return value == "RT_ActorActionState" or .is_class(value)
func get_class() -> String: return "RT_ActorActionState"


#### BUILT-IN ####



#### VIRTUALS ####


#### LOGIC ####




#### INPUTS ####



#### SIGNAL RESPONSES ####
