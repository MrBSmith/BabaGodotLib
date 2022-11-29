@tool
extends Node2D
class_name CircleUI

@export var radius : float = 50.0 : set = set_radius
@export var width : float = 4.0 : set = set_width

@export_range(0, 999) var nb_arc_segments : int = 1:
	set(value):
		if value != nb_arc_segments:
			nb_arc_segments = value
			nb_arc_segments_changed.emit()

signal nb_arc_segments_changed

#### ACCESSORS ####

func is_class(value: String): return value == "CircleUI" or super.is_class(value)
func get_class() -> String: return "CircleUI"

func set_radius(value: float) -> void:
	if value != radius:
		radius = value
		queue_redraw()


func set_width(value: float) -> void:
	if value != width:
		width = value
		queue_redraw()



#### BUILT-IN ####

func _ready() -> void:
	var __ = connect("nb_arc_segments_changed",Callable(self,"_on_nb_arc_segments_changed"))


#### VIRTUALS ####

func _draw() -> void:
	var nb_iter = (nb_arc_segments * 2)
	var segment_angle_len = deg_to_rad(360.0 / nb_iter)
	
	for i in range(nb_iter):
		if i % 2 == 1 && nb_iter != 2:
			continue
		
		var start_angle = i * segment_angle_len
		var end_angle = start_angle + segment_angle_len
		
		draw_arc(Vector2.ZERO, radius, start_angle,
				end_angle, 40, 
				Color.WHITE, width)


#### LOGIC ####


#### INPUTS ####



#### SIGNAL RESPONSES ####


func _on_nb_arc_segments_changed() -> void:
	queue_redraw()
