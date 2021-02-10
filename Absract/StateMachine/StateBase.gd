extends Node
class_name StateBase

# Abstract base class for a state in a statemachine

# Defines the behaviour of the entity possesing the statemachine 
# when the entity is in this state

# The enter_state is called every time the state is entered and exit_state when its exited
# the update of the currrent state is called every physics tick,  
# by the physics_process of the StateMachine 

onready var states_machine = get_parent()


# Called when the current state of the state machine is set to this node
func enter_state():
	pass
	
# Called when the current state of the state machine is switched to another one
func exit_state():
	pass

# Called every frames, for real time behaviour
# Use a return "State_node_name" or return Node_reference to change the current state of the state machine at a given time
func update(_delta):
	pass
