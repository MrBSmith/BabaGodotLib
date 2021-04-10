extends Node2D
class_name StatesMachine

# An implementation of the Finite State Machine design pattern
# Each state must inherit StateBase and be a child node of a StatesMachine node
# The states are distinguished by the name of their corresponding node

# Each state defines the behaviour of the entity possesing this statemachine
# when the entity is in this state
# You can refer to the main node using the keyword owner
# In that case the main node must be the root of the scene

# The default state is always the first in the tree unless the owner of the scene 
# as a default_state property (Must be a String corresponding to the name of a State node)

onready var current_state : Object = null
onready var previous_state : Object = null

signal state_changed


# Set the state to the first of the list
func _ready():
	yield(owner, "ready")
	
	var default = get("default_state") if get("default_state") != null else owner.get("default_state")
	
	if default != null && default != "":
		set_state(default)
	else:
		set_state(get_child(0))


# Call for the current state process at every frame of the physic process
func _physics_process(delta):
	if current_state == null:
		return
	var state_name = current_state.update_state(delta)
	if state_name:
		set_state(get_node(state_name))


# Returns the current state
func get_state() -> Object:
	return current_state


# Returns the name of the current state
func get_state_name() -> String:
	if current_state == null:
		return ""
	else:
		return current_state.name


# Set current_state at a new state, also set previous state, and emit a signal to notify the change, to anybody needing it 
func set_state(new_state):
	# if the given argument is a string, get the 
	if new_state is String:
		new_state = get_node_or_null(new_state)
	
	# Discard the method if the new_state is the current_state
	if new_state == current_state or new_state == null:
		return
	
	# Use the exit state function of the current state
	if current_state != null:
		current_state.exit_state()
	
	# Change the current state, and the previous state
	previous_state = current_state
	current_state = new_state
	
	# Use the enter_state function of the current state
	current_state.enter_state()
	
	emit_signal("state_changed", current_state.name)


# Set the state based on the id of the state (id of the node, ie possition in the hierachy)
func set_state_by_id(state_id: int):
	var state = get_child(state_id)
	if state == null:
		if state_id >= get_child_count() or state_id < 0:
			print_debug("The given state_id is out of bound")
		elif !state.is_class("StateBase"):
			print_debug("The child of the statemachine pointed by the state_id: " + String(state_id)
			 + " does not inherit StateBase")
		else:
			set_state(state)


# Returns true if a state with the given name is a direct child of the statemachine, and inherit StateBase
func has_state(state_name: String) -> bool:
	for state in get_children():
		if state.is_class("StateBase") && state.name == state_name:
			return true
	return false
