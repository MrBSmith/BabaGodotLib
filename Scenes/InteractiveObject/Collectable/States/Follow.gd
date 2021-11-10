extends StateBase
class_name Collectable_FollowState

#### ACCESSORS ####

func is_class(value: String): return value == "Collectable_FollowState" or .is_class(value)
func get_class() -> String: return "Collectable_FollowState"


#### BUILT-IN ####


#### VIRTUALS ####


func update_state(delta: float):
	owner.follow(delta)



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####
