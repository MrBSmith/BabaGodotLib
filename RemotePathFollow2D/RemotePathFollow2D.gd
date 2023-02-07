extends PathFollow2D
class_name RemotePathFollow2D

var moved_node_wr : WeakRef
var duration : float = 1.0
var is_ready = false

signal unit_offset_changed
signal path_finished

#### ACCESSORS ####

func set_unit_offset(value: float) -> void:
	.set_unit_offset(value)
	
	emit_signal("unit_offset_changed", unit_offset)


#### BUILT-IN ####


func _ready() -> void:
	var __ = connect("unit_offset_changed", self, "_on_unit_offset_changed")
	is_ready = true

#### VIRTUALS ####



#### LOGIC ####


func move_node_along_path(node: Node2D, backwards: bool = false, dur: float = 1.0) -> void:
	moved_node_wr = weakref(node)
	duration = dur
	
	var tween = create_tween()
	var __ = tween.connect("finished", self, "_on_tween_finished")
	var from = 0.0 if !backwards else 1.0
	var to = 1.0 if !backwards else 0.0
	
	tween.tween_method(self, "set_unit_offset", from, to, duration)



#### INPUTS ####



#### SIGNAL RESPONSES ####


func _on_tween_finished() -> void:
	emit_signal("path_finished")


func _on_unit_offset_changed(_unit_offset: float) -> void:
	if moved_node_wr == null:
		return
	
	var moved_node = moved_node_wr.get_ref()
	
	if moved_node == null:
		return
	
	moved_node.set_global_position(global_position)
