extends Transition
class_name MaskTransition

const POLY_GEN_EPSILON = 1.5
const NB_LAYERS = 3
const LAYER_INTERVAL = 0.6

@export var interval_curve : Curve
@export var window_size := Vector2(640.0, 360.0)
@export var dezoomed_scale := Vector2(10.0, 10.0)
@export var zoomed_scale := Vector2(0.5, 0.5)
@export var level_type_textures_dict : Dictionary = {}
@export var themes_dict : Dictionary

@onready var layers: Node2D = $Layers
@onready var pivot: Node2D = $"%Pivot"

var theme : Theme
var mask_poly_array : Array

signal theme_changed

func set_theme(value: Theme) -> void:
	if value != theme:
		theme = value
		theme_changed.emit()


func _ready() -> void:
	theme_changed.connect(_update_colors)
	hide()


func _update_colors() -> void:
	if !theme:
		push_warning("No theme given to level transition, fallback to default colors")
		return
	
	for layer_id in range(NB_LAYERS):
		var color_name = ""
		match(layer_id):
			0: color_name = "outer_transition_color"
			1: color_name = "middle_transition_color"
			2: color_name = "inner_transition_color"
		
		var color = theme.get_color(color_name, "")
		var polygon_layer = layers.get_child(layer_id)
		
		for side in polygon_layer.get_children():
			var result = side.get_node("Result")
			for poly in result.get_children():
				poly.set_color(color)


func _trigger(level_type: String) -> void:
	started.emit()
	var texture = level_type_textures_dict.get(level_type)
	set_theme(themes_dict.get(level_type))
	
	if texture == null:
		push_error("Texture of type %s not found" % level_type)
		return
	
	show()
	
	var image = texture.get_data()
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(image)
	var mask_rect = Rect2(Vector2.ONE, bitmap.get_size())
	var mask_poly = bitmap.opaque_to_polygons(mask_rect, POLY_GEN_EPSILON)[0]
	var mask_offset = (window_size - image.get_size()) / 2.0
	
	for i in range(mask_poly.size()):
		mask_poly[i] += mask_offset
	
	mask_poly_array = []
	
	for __ in range(NB_LAYERS):
		mask_poly_array.append(mask_poly)
	
	fade()
	
	await tween.finished
	
	hide()


func fade(duration := 2.0, mode : MODE = MODE.IN_OUT, delay := 0.0, pause_time := 0.5) -> void:
	if tween:
		tween.kill()
	
	tween = create_tween()
	layers.show()
	
	running = true
	var dur = duration / 2.0 if mode == MODE.IN_OUT else duration
	
	if mode != MODE.IN:
		for i in range(NB_LAYERS):
			var __ = tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			var ratio = smoothstep(0.0, float(NB_LAYERS), float(i))
			var interval = interval_curve.interpolate(ratio) * LAYER_INTERVAL
			__ = tween.parallel().tween_method(_set_mask_scale.bind(i), dezoomed_scale, zoomed_scale, dur).set_delay(interval + delay)
		
		await tween.finished
		
		if mode == MODE.IN_OUT:
			transition_middle.emit()
	
	if mode == MODE.IN_OUT and pause_time > 0.0:
		await get_tree().create_timer(pause_time).timeout
		transition_pause_finished.emit()
	
	if pause:
		await unpaused
	
	if mode != MODE.OUT:
		if tween:
			tween.kill()
		
		tween = create_tween()
		for i in range(NB_LAYERS):
			var id = NB_LAYERS - i - 1
			var ratio = smoothstep(0.0, float(NB_LAYERS), float(i))
			var interval = interval_curve.interpolate(ratio) * LAYER_INTERVAL
			var __ = tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
			__ = tween.parallel().tween_method(_set_mask_scale.bind(id), zoomed_scale, dezoomed_scale, duration).set_delay(interval + delay)
		
		await tween.finished
	
	running = false
	transition_finished.emit()


func _set_mask_scale(mask_scale: Vector2, mask_id: int) -> void:
	var poly = PackedVector2Array()
	poly.resize(mask_poly_array[mask_id].size())
	var center = window_size / 2.0
	
	for i in range(mask_poly_array[mask_id].size()):
		poly[i] = (mask_poly_array[mask_id][i] - center) * mask_scale + center
	
	var polygon_container: Node2D = layers.get_child(mask_id)
	
	for half in polygon_container.get_children():
		var screen_poly = half.get_node("Screen")
		var result_container = half.get_node("Result")
		
		var result_polygons = Geometry2D.clip_polygons(screen_poly.polygon, poly)
		
		for result in result_container.get_children():
			var id = result.get_index()
			if id in range(result_polygons.size()):
				result.set_polygon(result_polygons[id])
			else:
				result.set_polygon(PackedVector2Array())


func interupt_transition() -> void:
	super.interupt_transition()
	layers.hide()
