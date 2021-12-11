extends State
class_name StateMachine

# An implementation of the Finite State Machine design pattern
# Each state must inherit State and be a child node of a StateMachine node
# The states are distinguished by the name of their corresponding node

# Each state defines the behaviour of the entity possesing this statemachine when the entity is in this state
# You can refer to the main node using the keyword owner
# In that case the main node must be the root of the scene

# The default state is always the first in the tree unless the owner of the scene 
# has a default_state property (Must be a String corresponding to the name of a State node)

# States Machines can also be nested (Its children are also StateMachines)
# In that case the StateMachine behave also as a state, and the enter_state callback is called recursivly
# Note that nested StateMachines that are not the current_state of their parent should have their current_state to null
# That is why the exit_state function is setting the current state to null

var current_state : Object = null
var previous_state : Object = null
var default_state : Object = null
export var no_default_state : bool = false

# Usefull only if this instance of StateMachine is nested (ie its parent is also a StateMachine)
# When this state is entered, if this bool is true, reset the child state to the default one
export var reset_to_default : bool = false

# Called after the exit_state of the previous_state and before the enter_state of the current_state
signal state_changing(from_state, to_state)

# Called after the state have changed (After the enter_state callback)
signal state_changed(state)
signal state_changed_recursive(state)

func is_class(value: String): return value == "StateMachine" or .is_class(value)
func get_class() -> String: return "StateMachine"

#### BUILT-IN ####

# Set the state to the first of the list
func _ready():
	yield(owner, "ready")
	
	var __ = connect("state_changed", self, "_on_state_changed")
	
	if get_parent().is_class("StateMachine"):
		__ = connect("state_changed_recursive", get_parent(), "_on_State_state_changed_recursive")
	
	# Get the default_state
	var owner_default_state_name = owner.get("default_state")
	var owner_default_state = get_node_or_null(owner_default_state_name) if owner_default_state_name != null else null
	default_state = get_child(0) if owner_default_state == null else owner_default_state
	
	# Set the state to be the default one, unless we are in a nested StateMachine
	# Nested StateMachines shouldn't have a current_state if they are not the current_state of its parent
	if !is_nested() && !no_default_state:
		set_state(default_state)


# Call for the current state process at every frame of the physic process
func _physics_process(delta):
	if current_state == null:
		return
	var state_name = current_state.update_state(delta)
	if state_name:
		set_state(get_node(state_name))


#### LOGIC ####

# Returns the current state
func get_state() -> Object:
	return current_state


# Returns the name of the current state
func get_state_name() -> String:
	if current_state == null:
		return ""
	else:
		return current_state.name


# Set current_state at a new state, also set previous state, 
# and emit a signal to notify the change, to anybody needing it
# The new_state argument can either be a State or a String representing the name of the targeted State
func set_state(new_state):
	# This method can handle only String and States
	if not new_state is State and not new_state is String and new_state != null:
		return 
	
	# If the given argument is a string, get the node that has the name that correspond
	if new_state is String:
		new_state = get_node_or_null(new_state)
	
	# Discard the method if the new_state is the current_state
	if new_state == current_state:
		return
	
	# Use the exit state function of the current state
	if current_state != null:
		current_state.exit_state()
	
	previous_state = current_state
	current_state = new_state
	
	emit_signal("state_changing", previous_state, current_state)
	
	# Use the enter_state function of the current state
	if new_state != null && (!is_nested() or new_state.is_current_state()):
		current_state.enter_state()

	emit_signal("state_changed", current_state)


# Set the state based on the id of the state (id of the node, ie position in the hierachy)
func set_state_by_id(state_id: int):
	var state = get_child(state_id)
	if state == null:
		if state_id >= get_child_count() or state_id < 0:
			push_error("The given state_id is out of bound")
		
		elif !state.is_class("State"):
			push_error("The child of the statemachine pointed by the state_id: " + String(state_id)
			 + " does not inherit State")
	else:
		set_state(state)


# Returns true if a state with the given name is a direct child of the statemachine, and inherit State
func has_state(state_name: String) -> bool:
	for state in get_children():
		if state.is_class("State") && state.name == state_name:
			return true
	return false


func is_nested() -> bool:
	return get_parent().is_class("StateMachine")


# Set state by incrementing its id (id of the node, ie position in the hierachy)
func increment_state(increment: int = 1, wrapping : bool = true):
	var current_state_id = get_state().get_index()
	var id = wrapi(current_state_id + increment, 0, get_child_count()) if wrapping else current_state_id + increment 
	var state = get_child(id)
	
	if state == null or not state is State:
		while(!state is State):
			if wrapping:
				id = wrapi(id + increment, 0, get_child_count())
			else:
				id += increment
			state = get_child(id)
			if state == null && !wrapping:
				break
	
	if state == null:
		print_debug("There is no node at the given id: " + String(id))
	elif !(state is State):
		print_debug("The node found at the id: " + String(id) + " does not inherit State")
	else:
		set_state(state)


#### NESTED STATES MACHINES LOGIC ####
# Applies only if this StateMachine instance is nested (ie if it has a StateMachine as a parent)

func enter_state():
	if (reset_to_default && current_state != default_state) or current_state == null:
		set_state(default_state)
	else:
		current_state.enter_state()


func exit_state():
	set_state(null)


func update_state(delta: float):
	if current_state != null:
		current_state.update_state(delta)


func is_current_state() -> bool:
	var parent = get_parent()
	if parent is State or (parent.is_class("StateMachine") && parent.is_nested()):
		return parent.current_state == self && parent.is_current_state()
	else:
		return true


#### SIGNAL RESPONSES ####

func _on_state_changed(_state: Node) -> void:
	emit_signal("state_changed_recursive", current_state)


func _on_State_state_changed_recursive(_state: Node) -> void:
	emit_signal("state_changed_recursive", current_state)
