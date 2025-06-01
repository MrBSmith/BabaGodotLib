extends Node
class_name NodeFinder

static func find(node: Node, wanted_class: String) -> Array:
	var array = []
	for child in node.get_children():
		if is_obj_of_class(child, wanted_class):
			array.append(child)
	return array


static func find_first(node: Node, wanted_class: String) -> Node:
	for child in node.get_children():
		if is_obj_of_class(child, wanted_class):
			return child
	return null


static func find_recursive(node: Node, wanted_class: String, array: Array = []) -> Array:
	for child in node.get_children():
		if is_obj_of_class(child, wanted_class) and not child in array:
			array.append(child)
		
		if child.get_child_count() > 0:
			var __ = find_recursive(child, wanted_class, array)
	
	return array


static func is_obj_of_class(obj: Object, wanted_class: String) -> bool:
	if !is_instance_valid(obj):
		return false
	
	var script = obj.get_script()
	
	if script and is_script_of_class(script, wanted_class):
		return true
	else:
		return obj.is_class(wanted_class)


static func is_script_of_class(script: Script, wanted_class: String) -> bool:
	if !is_instance_valid(script):
		return false
	
	if script.get_global_name() == wanted_class:
		return true
	
	var parent_script = script.get_base_script()
	
	if parent_script:
		return is_script_of_class(parent_script, wanted_class)
	else:
		return false
