extends Node
class_name State

enum MODE {
	DEFAULT,
	TOGGLE,
	NON_INTERRUPTABLE
}


func get_class() -> String : return "State"
func is_class(value: String) -> bool: return value == "State" or .is_class(value)

export(MODE) var mode = MODE.DEFAULT

signal state_animation_finished

# Abstract base class for a state in a statemachine

# Defines the behaviour of the entity possesing the statemachine 
# when the entity is in this state

# The enter_state is called every time the state is entered and exit_state when its exited
# the update_state of the currrent state is called every physics tick,  
# by the physics_process of the StateMachine 

onready var states_machine = get_parent()


#### BUILT-IN ####

func _ready() -> void:
	if mode == MODE.NON_INTERRUPTABLE:
		var __ = connect("state_animation_finished", states_machine, "_on_non_interuptable_state_animation_finished")



#### CALLBACKS ####

# Called when the current state of the state machine is set to this node
func enter_state() -> void:
	pass

# Called when the current state of the state machine is switched to another one
func exit_state() -> void:
	pass

# Called every frames, for real time behaviour
# Use a return "State_node_name" or return Node_reference to change the current state of the state machine at a given time
func update_state(_delta: float) -> void:
	pass


#### LOGIC ###

func exit() -> void:
	match(mode):
		MODE.TOGGLE: 
			if states_machine.is_class("PushdownAutomata"):
				states_machine.go_to_previous_non_toggle_state()
			else:
				states_machine.set_state(states_machine.previous_state)
		
		MODE.NON_INTERRUPTABLE: 
			emit_signal("state_animation_finished")


# Check if the entity is in this state. Check reccursivly in cas of nested StateMachines/PushdownAutomata
func is_current_state() -> bool:
	if states_machine.has_method("is_current_state"):
		return states_machine.current_state == self && states_machine.is_current_state()
	else:
		return states_machine.current_state == self

