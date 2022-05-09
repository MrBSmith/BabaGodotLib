extends Resource
class_name StateCondition

var condition : String = ""
var target : Node

#### ACCESSORS ####

func is_class(value: String): return value == "StateCondition" or .is_class(value)
func get_class() -> String: return "StateCondition"


#### BUILT-IN ####

func _init(tar: Node, cond: String) -> void:
	target = tar
	condition = cond


#### VIRTUALS ####



#### LOGIC ####

func is_verified() -> bool:
	if target == null:
		return false
	
	var value = target.call(condition) if target.has_method(condition) else target.get(condition)
	
	if value is bool:
		return value
	else:
		push_error("The condition must be the name of a bool variable or the name of a fonction returning a bool value, current value is %s" % str(value))
		return false


#### INPUTS ####



#### SIGNAL RESPONSES ####
