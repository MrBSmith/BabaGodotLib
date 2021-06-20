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
	if target_name == "" or method_name == "":
		print("ERROR : The event %s has an undefined target and/or method to call" % name)
		return
	
	# Get the target(s) and store it in target_array
	var target_array : Array = []
	if target_as_group:
		target_array = get_tree().get_nodes_in_group(target_name)
	else:
		var current_scene_root = get_tree().get_current_scene()
		if current_scene_root.name == target_name:
			target_array.append(current_scene_root)
		else:
			target_array.append(current_scene_root.find_node(target_name))
	
	# Call the method in every target, and pass every argument in the array
	for target in target_array:
		if target.has_method(method_name) or GDScript:
			var call_def_funcref := funcref(target, method_name)
			call_def_funcref.call_funcv(arguments_array)
	
	# Queue free this event if it should be
	if queue_free_after_trigger:
		queue_free()
