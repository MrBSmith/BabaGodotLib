extends Event
class_name LevelEvent

export var autoload_target_name : String
export var target_path_array : Array
export var method_name : String = ""
export var arguments_array : Array = []

export var debug_logs : bool = false

# If this is true, the event will trigger only the first time play a level
export var once_per_level : bool = false

func is_class(value: String) -> bool: return value == "LevelEvent" or .is_class(value)
func get_class() -> String: return "LevelEvent"


func _ready() -> void:
	for child in get_children():
		if child is Area2D:
			child.connect("body_entered", self, "_on_area_body_entered")



func event():
	if event_disabled:
		return
	
	if delay > 0.0:
		yield(get_tree().create_timer(delay), "timeout")
	
	if debug_logs: print(name, " event triggered")
	
	if once_per_level:
		if PROGRESSION.is_level_visited(VIEW_MANAGER.level):
			return
	
	if !is_queued_for_deletion():
		method_call()
	
	.event()


# Call the given method in a single target or a group target
# Pass any number of arguments stored in the arguments_array to this method
func method_call():
	if method_name == "":
		push_error("The event %s has no method to call" % name)
		return
	
	var target_array : Array = []
	
	if autoload_target_name != "":
		var autoload = get_tree().get_root().get_node_or_null(autoload_target_name)
		
		if autoload:
			target_array.append(autoload)
	
	for target_path in target_path_array:
		var target = get_node_or_null(target_path)
		
		assert(target != null, "Target cannot be found at path %s" % str(target_path))
		
		target_array.append(target)
	
	# Call the method in every target, and pass every argument in the array
	for target in target_array:
		if target.has_method(method_name) or GDScript:
			if debug_logs: print(method_name, " called in ", target.name)
			
			var call_def_funcref := funcref(target, method_name)
			call_def_funcref.call_funcv(arguments_array)
		
		else:
			push_error("The event's %s target has no method called %s" % [name, method_name])



func _on_area_body_entered(_body: Node2D) -> void:
	event()
