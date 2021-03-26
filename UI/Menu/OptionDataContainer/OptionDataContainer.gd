extends Node
class_name OptionDataContainer

var object_ref : Object = null

var amount : int = INF
var icon_texture : Texture = null

#### ACCESSORS ####

func is_class(value: String): return value == "OptionDataContainer" or .is_class(value)
func get_class() -> String: return "OptionDataContainer"


#### BUILT-IN ####

func _init(obj: Object, _name: String, _amount : int = INF, _icon: Texture = null) -> void:
	object_ref = obj
	name = _name
	amount = _amount
	icon_texture = _icon


#### VIRTUALS ####



#### LOGIC ####

func clear():
	for child in get_children():
		child.queue_free()

#### INPUTS ####



#### SIGNAL RESPONSES ####
