tool
extends Node2D
class_name CircleUI

export var radius : float = 50.0 setget set_radius
export var width : float = 4.0 setget set_width

export(int, 1, 999) var nb_arc_segments : int = 1 setget set_nb_arc_segments

signal nb_arc_segments_changed

#### ACCESSORS ####

func is_class(value: String): return value == "CircleUI" or .is_class(value)
func get_class() -> String: return "CircleUI"

func set_radius(value: float) -> void:
	if value != radius:
		radius = value
		update()


func set_width(value: float) -> void:
	if value != width:
		width = value
		update()


func set_nb_arc_segments(value: int) -> void:
	if value != nb_arc_segments:
		nb_arc_segments = value
		emit_signal("nb_arc_segments_changed")


#### BUILT-IN ####

func _ready() -> void:
	var __ = connect("nb_arc_segments_changed", self, "_on_nb_arc_segments_changed")


#### VIRTUALS ####

func _draw() -> void:
	var nb_iter = (nb_arc_segments * 2)
	var segment_angle_len = deg2rad(360.0 / nb_iter)
	
	for i in range(nb_iter):
		if i % 2 == 1 && nb_iter != 2:
			continue
		
		var start_angle = i * segment_angle_len
		var end_angle = start_angle + segment_angle_len
		
		draw_arc(Vector2.ZERO, radius, start_angle,
				end_angle, 40, 
				Color.white, width)


#### LOGIC ####


#### INPUTS ####



#### SIGNAL RESPONSES ####


func _on_nb_arc_segments_changed() -> void:
	update()
