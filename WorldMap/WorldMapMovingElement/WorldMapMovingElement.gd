tool
extends Node2D
class_name WorldMapMovingElement

export var speed : float = 100.0

onready var tween_node = $Tween

var moving : bool = false setget set_moving, is_moving
var current_node : WorldMapNode = null setget set_current_node, get_current_node

var path := PoolVector2Array()

signal movement_finished
signal path_finished

#### ACCESSORS ####

func is_class(value: String): return value == "WorldMapMovingElement" or .is_class(value)
func get_class() -> String: return "WorldMapMovingElement"

func set_moving(value: bool): moving = value
func is_moving() -> bool: return moving

func set_current_node(value: WorldMapNode): current_node = value
func get_current_node() -> WorldMapNode: return current_node

#### BUILT-IN ####

func _ready() -> void:
	set_physics_process(false)
	var __ = connect("movement_finished", self, "_on_movement_finished")


func _process(_delta: float) -> void:
	if Engine.editor_hint && current_node != null:
		set_position(current_node.get_position())


func _physics_process(delta: float) -> void:
	if path.empty():
		return
	
	if is_arrived(path[0]):
		path.remove(0)
	
	if !path.empty():
		move(path[0], delta)
	else:
		emit_signal("movement_finished")



#### VIRTUALS ####



#### LOGIC ####

func move_to_node(node: WorldMapNode, interpol: bool = true):
	if node == null or is_moving():
		 return
	
	var bind = owner.get_bind(current_node, node)
	var move_path = bind.get_point_path()
	
	# If we need move along the bind in backwards order
	if bind.origin == node:
		move_path.invert()
	
	set_current_node(node)
	
	move_along_path(move_path, interpol)


func move_along_path(move_path: PoolVector2Array, interpol: bool = true):
	path = move_path
	
	if interpol:
		for i in range(path.size()):
			
			var point = path[i]
			if i == 0:
				continue
			
			move_interpol(point)
			
			yield(self, "movement_finished")
	else:
		set_physics_process(true)
		yield(self, "movement_finished")
	
	set_physics_process(false)
	emit_signal("path_finished")


func move_interpol(dest: Vector2, ease_type: int = Tween.EASE_IN_OUT):
	tween_node.interpolate_property(self, "global_position",
		get_global_position(), dest,
		0.7, Tween.TRANS_CUBIC, ease_type)
	
	tween_node.start()
	
	moving = true
	
	yield(tween_node, "tween_all_completed")
	emit_signal("movement_finished")


func move(dest: Vector2, delta: float):
	var dir = get_global_position().direction_to(dest)
	var vel = dir * speed * delta
	
	if is_arrived(dest):
		global_position = dest
	else:
		global_position += vel


func is_arrived(dest: Vector2) -> bool:
	var vel_len := speed * get_physics_process_delta_time()
	return get_global_position().distance_to(dest) < vel_len


#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_movement_finished():
	moving = false

