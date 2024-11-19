extends PathFollow2D
class_name RemotePathFollow2D

onready var path : Path2D = get_parent()

const MIN_DIST_TO_POINT = 10.0

var moved_node_wr : WeakRef
var moving : bool = false
var duration : float = 1.0
var is_ready = false
var tween : SceneTreeTween = null

var unreached_points = []

signal unit_offset_changed
signal path_finished
signal reach_path_point(next_point_dir)

#### ACCESSORS ####

func set_unit_offset(value: float) -> void:
	.set_unit_offset(value)
	
	emit_signal("unit_offset_changed", unit_offset)


#### BUILT-IN ####


func _ready() -> void:
	var __ = connect("unit_offset_changed", self, "_on_unit_offset_changed")
	is_ready = true


func _physics_process(_delta: float) -> void:
	if !moving or unreached_points.empty():
		return
	
	for i in [0, unreached_points.size() - 1]:
		var point = unreached_points[i]
		
		if position.distance_to(point) <= MIN_DIST_TO_POINT:
			unreached_points.remove(i)
			var dir_to_next = Vector2.ZERO if unreached_points.empty() else point.direction_to(unreached_points[0])
			emit_signal("reach_path_point", dir_to_next)
			break



#### VIRTUALS ####



#### LOGIC ####


func move_node_along_path(node: Node2D, backwards: bool = false, dur: float = 1.0) -> void:
	moved_node_wr = weakref(node)
	duration = dur
	moving = true
	
	unreached_points = _get_path_points()
	
	tween = create_tween()
	var __ = tween.connect("finished", self, "_on_tween_finished")
	var from = 0.0 if !backwards else 1.0
	var to = 1.0 if !backwards else 0.0
	
	__ = tween.tween_method(self, "set_unit_offset", from, to, duration)
	
	yield(tween, "finished")
	moving = false


func _get_path_points() -> Array:
	if !path or !path.curve:
		return []
	
	var path_points = []
	
	for i in range(path.curve.get_point_count()):
		path_points.append(path.curve.get_point_position(i))
	
	return path_points


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


func _on_body_destroyed() -> void:
	if tween: tween.kill()
	queue_free()
