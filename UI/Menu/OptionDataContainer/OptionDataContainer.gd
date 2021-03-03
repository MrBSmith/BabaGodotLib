extends Node
class_name OptionDataContainer

var amount : int = INF
var icon : Texture = null

#### ACCESSORS ####

func is_class(value: String): return value == "OptionDataContainer" or .is_class(value)
func get_class() -> String: return "OptionDataContainer"


#### BUILT-IN ####

func _init(_name: String, _amount : int = INF, _icon: Texture = null) -> void:
	name = _name
	amount = _amount
	icon = _icon


#### VIRTUALS ####



#### LOGIC ####

func clear():
	for child in get_children():
		child.queue_free()

#### INPUTS ####



#### SIGNAL RESPONSES ####
