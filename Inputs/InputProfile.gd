extends Object
class_name InputProfile

var dict := Dictionary()
var is_customizable = false


#### ACCESSORS ####

func is_class(value: String): return value == "InputProfile" or .is_class(value)
func get_class() -> String: return "InputProfile"


#### BUILT-IN ####

func _init(_dict: Dictionary, _is_customizable: bool) -> void:
	dict = _dict
	is_customizable = _is_customizable


#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####
