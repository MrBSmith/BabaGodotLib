extends State
class_name ActorLandState

#### ACCESSORS ####

func is_class(value: String): return value == "ActorLandState" or .is_class(value)
func get_class() -> String: return "ActorLandState"


#### BUILT-IN ####

func _ready() -> void:
	pass

#### VIRTUALS ####


#### LOGIC ####


func exit_toggle_state() -> void:
	states_machine.set_state("Idle")


#### INPUTS ####



#### SIGNAL RESPONSES ####

