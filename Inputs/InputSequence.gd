extends Node
class_name InputSequence

var action_buffer : Array = []

export var action_sequence : Array = []
export var target_node_path : NodePath
export var method : String = ""
export var arguments : Array = []
export var input_time_threshold : float = 1.0

export var print_logs := false

export var matching_inputs_array : Array = []

onready var cooldown = Cooldown.new()
onready var target_node = owner if target_node_path.is_empty() or target_node_path == null else get_node(target_node_path)

#### ACCESSORS ####

func is_class(value: String): return value == "InputSequence" or .is_class(value)
func get_class() -> String: return "InputSequence"


#### BUILT-IN ####

func _ready() -> void:
	add_child(cooldown)
	cooldown.set_wait_time(input_time_threshold)
	cooldown.connect("timeout", self, "_on_cooldown_timeout")


#### VIRTUALS ####



#### LOGIC ####

func action(event: InputEvent) -> void:
	if !cooldown.is_inside_tree() or !target_node:
		return
	
	if action_sequence.empty():
		push_warning("The action_sequence array is empty; the sequence can never be fullfiled")
		return
	
	# Check if the event correseponds to the next wanted InputEvent in the action_sequence
	# If it does, append to the buffer
	var new_input_id = action_buffer.size()
	
	if action_sequence[new_input_id].input_event_corresponds(event):
		
		if new_input_id != 0:
			var matching_ids = _get_matching_ids_array(new_input_id)
			if print_logs && matching_ids.empty():
				print("No matching ids")

			if !is_input_matching(event, matching_ids):
				if print_logs: print("The sequence didn't match, aborting")
				abort()
				return
		
		if action_buffer.empty():
			cooldown.start()
			if print_logs:
				print("action sequence started")
		
		if print_logs:
			print(action_sequence[new_input_id].actions_array)
		
		action_buffer.append(event)
	
	# Check if the sequence is valid
	if action_buffer.size() == action_sequence.size():
		trigger()
	
	elif action_buffer.size() > action_sequence.size():
		push_error("The action buffer is longer the the action sequence, aborting")
		abort()


func is_input_matching(event: InputEvent, match_ids_array: PoolIntArray) -> bool:
	for id in match_ids_array:
		if id < action_buffer.size():
			var matching_event = action_buffer[id]
			
			var event_actions = Utils.input_find_matching_actions(event)
			var matching_event_actions = Utils.input_find_matching_actions(matching_event)
			
			if event_actions != matching_event_actions:
				return false
	return true


func _get_matching_ids_array(id: int) -> PoolIntArray:
	for input_ids_array in matching_inputs_array:
		if id in input_ids_array:
			return input_ids_array
	return PoolIntArray()


func abort() -> void:
	if print_logs:
		print("sequence aborted")
		print(action_buffer)
	
	_reset_sequence()


func trigger() -> void:
	if print_logs:
		print("sequence triggered")
		print(action_buffer)
	
	target_node.callv(method, arguments)
	_reset_sequence()


func _reset_sequence() -> void:
	cooldown.stop()
	action_buffer = []


#### INPUTS ####



#### SIGNAL RESPONSES ####


func _on_cooldown_timeout() -> void:
	abort()
