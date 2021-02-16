extends ActorStateBase
class_name ActorActionState

#### ACCESSORS ####

func is_class(value: String): return value == "ActorActionState" or .is_class(value)
func get_class() -> String: return "ActorActionState"


#### BUILT-IN ####



#### VIRTUALS ####



#### LOGIC ####

func is_obj_interactable(obj: Object) -> bool:
	var interactables = owner.get("interactables")
	
	if interactables == null:
		return true
	
	for string in interactables:
		if obj.is_class(string):
			return true
	return false


#### INPUTS ####



#### SIGNAL RESPONSES ####
