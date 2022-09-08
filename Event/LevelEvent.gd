extends Event
class_name LevelEvent

export var target_name : String = ""
export var target_as_group : bool = false
export var method_name : String = ""
export var arguments_array : Array = []
export var queue_free_after_trigger : bool = true


func event():
	method_call()


# Call the given method in a single target or a group target
# Pass any number of arguments stored in the arguments_array to this method
func method_call():
	# Check for an empty field, send an error if there is one
	if target_name == "":
		push_error("The event %s has no target_name to call" % name)
		return
	
	elif method_name == "":
		push_error("The event %s has no method to call" % name)
		return
	
	# Get the target(s) and store it in target_array
	var target_array : Array = []
	if target_as_group:
		target_array = get_tree().get_nodes_in_group(target_name)
	else:
		var level = GAME.current_level
		if level == null:
			push_error("The current level is null, the event couldn't trigger")
			return
		
		if level.name == target_name:
			target_array.append(level)
		else:
			var target = level.find_node(target_name)
			if target != null:
				target_array.append(target)
		
	# Call the method in every target, and pass every argument in the array
	for target in target_array:
		if target.has_method(method_name) or GDScript:
			var call_def_funcref := funcref(target, method_name)
			call_def_funcref.call_funcv(arguments_array)
		
		else:
			push_error("The event's %s target has no method called %s" % [name, method_name])
	
	# Queue free this event if it should be
	if queue_free_after_trigger:
		queue_free()
