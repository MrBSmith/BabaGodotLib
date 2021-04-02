extends StatesMachine
class_name PushdownAutomata

var state_queue : Array = []
var state_index : int = -1

export var state_queue_max_size : int = 5

#### ACCESSORS ####

func is_class(value: String): return value == "PushdownAutomata" or .is_class(value)
func get_class() -> String: return "PushdownAutomata"


#### BUILT-IN ####



#### VIRTUALS ####



#### LOGIC ####

func set_state(state):
	.set_state(state)
	
	if state == null or state == "":
		return
	
	if state_index == state_queue.size() - 1:
		state_queue.append(state)
		if state_queue.size() > state_queue_max_size:
			state_queue.remove(0)
		else:
			state_index += 1
	else:
		for i in range(state_queue.size() - state_index - 1):
			state_queue.remove(state_index + i + 1)
		
		state_queue.append(state)
		state_index += 1


func go_to_state_by_index(id: int):
	if id == state_index : return
	
	if id < 0 or id > state_queue.size() - 1:
		print_debug("The given index: " + String(id) + "isn't inside the queue bouderies")
	
	state_index = id
	.set_state(state_queue[id])


func go_to_previous_state():
	if state_index == 0:
		print_debug("There is no previous state - state_index is currently 0")
		return
	
	go_to_state_by_index(state_index - 1)


func go_to_next_state():
	if state_index == state_queue.size() - 1:
		print_debug("There is no next state - the current index is the last of the queue")
		return
	
	go_to_state_by_index(state_index + 1)



#### INPUTS ####



#### SIGNAL RESPONSES ####
