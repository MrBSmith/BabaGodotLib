extends Node
class_name NodeUtils

static func clear(node: Node) -> void:
	var last_child = null

	for child in node.get_children():
		last_child = child
		child.queue_free.call_deferred()

	if last_child and last_child.is_inside_tree():
		await last_child.tree_exited


static func find(node: Node, wanted_class: Variant) -> Array:
	var array = []
	for child in node.get_children():
		if is_instance_of(node, wanted_class):
			array.append(child)
	return array


static func find_first(node: Node, wanted_class: Variant) -> Node:
	for child in node.get_children():
		if is_instance_of(node, wanted_class):
			return child
	return null


static func find_recursive(node: Node, wanted_class: Variant, array: Array = []) -> Array:
	for child in node.get_children():
		if is_instance_of(node, wanted_class) and not child in array:
			array.append(child)
		
		if child.get_child_count() > 0:
			var __ = find_recursive(child, wanted_class, array)
	
	return array


static func get_center_position(control: Control) -> Vector2:
	return control.position + control.size / 2.0


static func get_center_global_position(control: Control) -> Vector2:
	return control.global_position + control.size / 2.0
