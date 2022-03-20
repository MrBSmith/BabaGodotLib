extends Resource
class_name InputSequenceElement

export var actions_array : Array = []

# A dictionary representing the state the InputEvent must be in
# Each key can be either a property or a method name (A getter typically)
# the property of the InputEvent must then have the same value as the value value correponding to it
# or the value returned by the method

# The method must retruns a value & takes no arguments or it will throw an error message
export var state_dict : Dictionary = {}

#### ACCESSORS ####

func is_class(value: String): return value == "InputSequenceElement" or .is_class(value)
func get_class() -> String: return "InputSequenceElement"


#### BUILT-IN ####



#### VIRTUALS ####



#### LOGIC ####

func input_event_corresponds(event: InputEvent) -> bool:
	if !_is_event_in_action_list(event):
		return false
	
	for key in state_dict.keys():
		if event.has_method(key):
			if event.call(key) != state_dict[key]:
				return false
		
		elif event.get(key) != state_dict[key]:
			return false
		
	return true


func _is_event_in_action_list(event: InputEvent) -> bool:
	for action in actions_array:
		if event.is_action(action):
			return true
	return false


#### INPUTS ####



#### SIGNAL RESPONSES ####
