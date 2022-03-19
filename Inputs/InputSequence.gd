extends Node
class_name InputSequence

var action_buffer := PoolStringArray()

export var keyword_sequence : PoolStringArray = []
export var target_node_path : NodePath
export var method : String = ""
export var arguments : Array = []
export var input_time_threshold : float = 1.0

# A list of keywords the action MUST have or it will be discarded
export var action_filter_keyword : PoolStringArray = []

# When an action has a keyword filter in it, all other actions must have the same one for the sequence to be triggered
export var keep_same_filter : bool = false

export var print_logs := false

onready var cooldown = Cooldown.new()
onready var target_node = owner if target_node_path.is_empty() or target_node_path == null else get_node(target_node_path)

var buffered_filter_keyword : String = "" 

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

func action(action: String) -> void:
	if _must_action_be_filtered(action) or !cooldown.is_inside_tree() or !target_node:
		return
	
	if keyword_sequence.empty():
		push_warning("The keyword_sequence array is empty; the sequence can never be fullfiled")
		return
	
	if action_buffer.empty():
		if keyword_sequence[0].is_subsequence_of(action):
			cooldown.start()
		else:
			return
	
	action_buffer.append(action)
	
	if action_buffer.size() == keyword_sequence.size():
		if _is_sequence_valid():
			trigger()
		else:
			abort()


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
	action_buffer = PoolStringArray()
	buffered_filter_keyword = ""


func _must_action_be_filtered(action: String) -> bool:
	for keyword in action_filter_keyword:
		if keep_same_filter && buffered_filter_keyword != "":
			if buffered_filter_keyword.is_subsequence_of(action):
				return false
		else:
			if keyword.is_subsequence_of(action):
				buffered_filter_keyword = keyword
				return false
	return true


func _is_sequence_valid() -> bool:
	if action_buffer.size() != keyword_sequence.size():
		return false
	
	for i in range(action_buffer.size()):
		if !keyword_sequence[i].is_subsequence_of(action_buffer[i]):
			return false
	return true


#### INPUTS ####



#### SIGNAL RESPONSES ####


func _on_cooldown_timeout() -> void:
	abort()
