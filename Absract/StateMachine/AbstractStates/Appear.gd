extends StateBase
class_name AppearState

#### ACCESSORS ####

func is_class(value: String): return value == "AppearState" or .is_class(value)
func get_class() -> String: return "AppearState"


#### BUILT-IN ####



#### VIRTUALS ####



#### LOGIC ####

func enter_state():
	var tween : Tween = owner.tween_node
	
	tween.interpolate_method(owner, "set_shader_param", 0.0, 1.0, 1.0, 
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	tween.start()
	
	yield(tween, "tween_all_completed")
	
	if states_machine.has_state("Visible"):
		states_machine.set_state("Visible")
	else:
		states_machine.increment_state()

func exit_state():
	pass

#### INPUTS ####



#### SIGNAL RESPONSES ####
