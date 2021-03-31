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

# Set current_state at a new state, also set previous state, and emit a signal to notify the change, to anybody needing it 
func set_state(new_state):
	# if the given argument is a string, get the 
	if new_state is String:
		new_state = get_node(new_state)
	
	# Discard the method if the new_state is the current_state
	if new_state == current_state:
		return
	
	# Use the exit state function of the current state
	if current_state != null:
		current_state.exit_state()
	
	# Change the current state, and the previous state
	previous_state = current_state
	current_state = new_state
	
	if is_current_state():
		# Use the enter_state function of the current state
		if new_state != null:
			current_state.enter_state()
		
		emit_signal("state_changed", current_state.name)


func is_current_state() -> bool:
	if states_machine.has_method("is_current_state"):
		return states_machine.current_state == self && states_machine.is_current_state()
	else:
		return states_machine.current_state == self


#### INPUTS ####



#### SIGNAL RESPONSES ####
