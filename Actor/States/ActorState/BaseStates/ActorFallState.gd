extends State
class_name ActorFallState

#### BUILT-IN ####


#### VIRTUALS ####

func update_state(_delta):
	if owner.is_on_floor():
		return "Idle"


#### SIGNAL RESPONSES ####



