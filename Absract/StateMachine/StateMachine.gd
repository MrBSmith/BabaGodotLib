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

onready var current_state : StateBase = null
onready var previous_state : StateBase = null

signal state_changed


# Set the state to the first of the list
func _ready():
	yield(owner, "ready")
	if owner.get("default_state") && owner.default_state != "":
		set_state(owner.default_state)
	else:
		set_state(get_child(0))


# Call for the current state process at every frame of the physic process
func _physics_process(delta):
	if current_state == null:
		return
	var state_name = current_state.update(delta)
	if state_name:
		set_state(get_node(state_name))


# Returns the current state
func get_state() -> StateBase:
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
	
	# Use the enter_state function of the current state
	if new_state != null:
		current_state.enter_state()
	
	emit_signal("state_changed", current_state.name)
