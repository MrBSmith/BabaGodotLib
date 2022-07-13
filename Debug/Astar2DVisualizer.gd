extends Node2D
class_name Astar2DVisualizer

var astar : AStar2D
export var cell_size := Vector2.ONE

export var connections_color := Color.blue
export var connection_width : float = 3.0

export var points_color := Color.blue
export var points_radius : float = 4.0

export var id_key : int = 666

#### ACCESSORS ####

func is_class(value: String): return value == "Astar2DVisualizer" or .is_class(value)
func get_class() -> String: return "Astar2DVisualizer"


#### BUILT-IN ####



#### VIRTUALS ####



#### LOGIC ####

func _draw() -> void:
	if astar == null:
		return
	
	for point_id in astar.get_points():
		var point = astar.get_point_position(point_id)
		draw_circle(point * cell_size, points_radius, points_color)
		
		for connected_point_id in astar.get_point_connections(point_id):
			var connected_point = astar.get_point_position(connected_point_id)
			
			draw_line(point * cell_size, connected_point * cell_size, connections_color, connection_width)





#### INPUTS ####



#### SIGNAL RESPONSES ####
