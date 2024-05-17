tool
class_name SmoothLine
extends Line2D

export var line_curve : Curve2D setget set_line_curve

export(float) var spline_length := 100.0
export(bool) var _smooth setget _set_smooth

signal smooth_changed(value)
signal line_curve_changed(curve)

#### ACCESSORS ####

func _set_smooth(value: bool) -> void:
	if value != _smooth:
		_smooth = value
		emit_signal("smooth_changed", _smooth)


func set_line_curve(value: Curve2D) -> void:
	line_curve = value
	emit_signal("line_curve_changed", value)


#### BUILT-IN ####

func _ready() -> void:
	var __ = connect("smooth_changed", self, "_on_smooth_changed")
	__ = connect("line_curve_changed", self, "_on_line_curve_changed")


#### VIRTUALS ####



#### LOGIC ####


func _get_spline(id: int):
	var last_point = _get_point(id - 1)
	var next_point = _get_point(id + 1)
	var spline = last_point.direction_to(next_point) * spline_length
	return spline


func _get_point(id: int):
	var point_count = line_curve.get_point_count()
	id = wrapi(id, 0, point_count - 1)
	return line_curve.get_point_position(id)


func line_update() -> void:
	if _smooth:
		smooth_update()
	else:
		_straighten()
	
	set_points(line_curve.get_baked_points())


func smooth_update() -> void:
	if !_smooth: return

	var point_count = line_curve.get_point_count()
	for i in point_count:
		var spline = _get_spline(i)
		line_curve.set_point_in(i, -spline)
		line_curve.set_point_out(i, spline)


func _straighten() -> void:
	if _smooth: return
	for i in line_curve.get_point_count():
		line_curve.set_point_in(i, Vector2())
		line_curve.set_point_out(i, Vector2())


#### INPUTS ####



#### SIGNAL RESPONSES ####



func _on_smooth_changed(_value: bool) -> void:
	line_update()


func _on_line_curve_changed(_value: Curve2D) -> void:
	line_update()
