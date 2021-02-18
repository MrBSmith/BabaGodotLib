extends Node2D
class_name RenderPart

var altitude : int setget set_altitude, get_altitude

var current_cell : Vector3 setget set_current_cell, get_current_cell
var object_ref : Node = null setget set_object_ref, get_object_ref 

var part_tween_node : PartTween = null
var sprite_node = null

var anim_delay_timer : Timer

signal cell_changed(part, cell)


#### ACCESSORS ####

func is_class(value: String): return value == "RenderPart" or .is_class(value)
func get_class() -> String: return "RenderPart"

func set_current_cell(value: Vector3):
	if current_cell != value:
		current_cell = value
		emit_signal("cell_changed", self, current_cell)

func get_current_cell() -> Vector3: return current_cell

func set_object_ref(value: Node): object_ref = value
func get_object_ref() -> Node: return object_ref

func set_altitude(value: int): altitude = value
func get_altitude() -> int: return altitude


#### BUILT-IN ####

func _ready() -> void:
	part_tween_node = PartTween.new()
	anim_delay_timer = Timer.new()
	
	add_child(part_tween_node)
	add_child(anim_delay_timer)


#### VIRTUALS ####



#### LOGIC ####

func appear(delay: float = 0.0, duration: float = 0.5):
	sprite_node.position = Vector2(0, -GAME.SCREEN_SIZE.y)
	
	if delay != 0.0:
		anim_delay_timer.start(delay)
		yield(anim_delay_timer, "timeout")
	
	part_tween_node.target_node = sprite_node
	part_tween_node.appear(duration)


func disappear(delay: float = 0.0, duration: float = 0.5):
	if delay != 0.0:
		anim_delay_timer.start(delay)
		yield(anim_delay_timer, "timeout")
	
	part_tween_node.target_node = sprite_node
	part_tween_node.disapear(duration)


func start_sin_move(magnitude: int, delay: float = 0.0, duration: float = 1.0, nb_wave: int = 1):
	if delay != 0.0:
		anim_delay_timer.start(delay)
		yield(anim_delay_timer, "timeout")
	
	part_tween_node.start_sin_move(sprite_node, magnitude, duration, nb_wave)


#### INPUTS ####



#### SIGNAL RESPONSES ####

