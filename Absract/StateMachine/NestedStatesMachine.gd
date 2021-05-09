extends StatesMachine
class_name NestedStatesMachine

onready var states_machine = get_parent()

#### ACCESSORS ####

func is_class(value: String): return value == "NestedStatesMachine" or .is_class(value)
func get_class() -> String: return "NestedStatesMachine"


#### BUILT-IN ####



#### VIRTUALS ####

func enter_state():
	current_state.enter_state()

func exit_state():
	current_state.exit_state()

func update_state():
	current_state.update_state()


#### LOGIC ####


func is_current_state() -> bool:
	if states_machine.has_method("is_current_state"):
		return states_machine.current_state == self && states_machine.is_current_state()
	else:
		return states_machine.current_state == self


#### INPUTS ####



#### SIGNAL RESPONSES ####
