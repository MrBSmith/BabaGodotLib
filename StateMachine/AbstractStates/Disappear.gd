extends State
class_name Disappear

#### ACCESSORS ####

func is_class(value: String): return value == "Disappear" or .is_class(value)
func get_class() -> String: return "Disappear"


#### BUILT-IN ####



#### VIRTUALS ####



#### LOGIC ####

func enter_state():
	var tween : Tween = owner.tween_node
	var shader_material = owner.get_material()
	
	if shader_material != null:
		var __ = tween.interpolate_property(shader_material, "shader_param/amount", 0.0, 1.0, 1.0, 
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	else:
		var __ = tween.interpolate_property(owner, "modulate", owner.get_modulate(), Color.transparent,
		1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	var __ = tween.start()
	yield(tween, "tween_all_completed")
	
	if states_machine.has_state("Visible"):
		states_machine.set_state("Visible")
	else:
		states_machine.increment_state()

#### INPUTS ####



#### SIGNAL RESPONSES ####
