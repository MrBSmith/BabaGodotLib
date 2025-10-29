extends Node
class_name NodeUtils

static func clear(node: Node) -> void:
	var last_child = null

	for child in node.get_children():
		last_child = child
		child.queue_free.call_deferred()

	if last_child and last_child.is_inside_tree():
		await last_child.tree_exited


static func get_class_name(obj: Object) -> String:
	var script = obj.get_script()
	if script:
		var global_name = script.get_global_name()
		if !global_name.is_empty():
			return global_name
		else:
			return obj.get_class()
	else:
		return obj.get_class()


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


static func get_center_position(obj: CanvasItem) -> Vector2:
	return obj.position + obj.size / 2.0


static func get_center_global_position(obj: CanvasItem) -> Vector2:
	return obj.global_position + obj.size / 2.0


static func get_position_relative_to_canvas(obj: CanvasItem) -> Vector2:
	var canvas_layer = obj.get_canvas_layer_node()
	if canvas_layer.follow_viewport_enabled:
		return obj.global_position + canvas_layer.get_final_transform().origin
	else:
		return obj.global_position


static func get_center_relative_to_canvas_layer(obj: CanvasItem) -> Vector2:
	return get_position_relative_to_canvas(obj) + obj.size / 2.0


static func canvas_relative_to_classic_position(pos: Vector2, obj: CanvasItem) -> Vector2:
	var canvas_layer = obj.get_canvas_layer_node()
	if canvas_layer.follow_viewport_enabled:
		return pos - canvas_layer.get_final_transform().origin
	else:
		return pos
