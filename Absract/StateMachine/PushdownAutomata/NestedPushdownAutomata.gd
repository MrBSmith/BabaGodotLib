extends PushdownAutomata
class_name NestedPushdownAutomata

onready var states_machine = get_parent()

# When this state is entered, if this bool is true, reset the child state to the default one
export var reset_to_default : bool = false
export var default_state = ""

#### ACCESSORS ####

func is_class(value: String): return value == "NestedPushdownAutomata" or .is_class(value)
func get_class() -> String: return "NestedPushdownAutomata"


#### BUILT-IN ####

func _enter_tree() -> void:
	pass

#### VIRTUALS ####

func enter_state():
	if reset_to_default:
		set_state_to_default()
	
	if is_current_state():
		current_state.enter_state()

func exit_state():
	current_state.exit_state()

func update_state(delta: float):
	current_state.update_state(delta)


#### LOGIC ####

func is_current_state() -> bool:
	if states_machine.has_method("is_current_state"):
		return states_machine.current_state == self && states_machine.is_current_state()
	else:
		return states_machine.current_state == self



#### INPUTS ####



#### SIGNAL RESPONSES ####
