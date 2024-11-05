extends TransitionLayer
class_name IconMaskTransition

const POLY_GEN_EPSILON = 1.5

export var dezoomed_scale := Vector2(10.0, 10.0)
export var zoomed_scale := Vector2(0.5, 0.5)
export var level_type_textures_dict : Dictionary = {}

onready var pivot: Node2D = $"%Pivot"
onready var polygon_container: Node2D = $Polygons

var mask_poly : PoolVector2Array

func _ready() -> void:
	var __ = EVENTS.connect("level_transition", self, "_trigger")
	hide()


func _trigger(level_type: String) -> void:
	var texture = level_type_textures_dict.get(level_type)
	
	if texture == null:
		push_error("Texture of type %s not found" % level_type)
		return
	
	show()
	
	var image = texture.get_data()
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(image)
	var mask_rect = Rect2(Vector2.ONE, bitmap.get_size())
	mask_poly = bitmap.opaque_to_polygons(mask_rect, POLY_GEN_EPSILON)[0]
	var mask_offset = (GAME.window_size - image.get_size()) / 2.0
	
	for i in range(mask_poly.size()):
		mask_poly[i] += mask_offset
	
	fade()
	
	yield(EVENTS, "transition_finished")
	yield(tween, "finished")
	
	hide()


func fade(fade_time := 2.3, fade_mode : int = FADE_MODE.FADE_IN_OUT, delay := 0.0, pause_time := 1.0) -> void:
	if tween:
		tween.kill()
	
	tween = create_tween()
	
	running = true
	var duration = fade_time / 2.0 if fade_mode == FADE_MODE.FADE_IN_OUT else fade_time
	
	if fade_mode != FADE_MODE.FADE_IN:
		var __ = tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		__ = tween.tween_method(self, "_set_mask_scale", dezoomed_scale, zoomed_scale, duration).set_delay(delay)
		
		yield(tween, "finished")
		
		if fade_mode == FADE_MODE.FADE_IN_OUT:
			EVENTS.emit_signal("transition_middle")
	
	if fade_mode == FADE_MODE.FADE_IN_OUT && pause_time > 0.0:
		yield(get_tree().create_timer(pause_time), "timeout")
		EVENTS.emit_signal("transition_pause_finished")
	
	if pause:
		yield(self, "unpaused")
	
	if fade_mode != FADE_MODE.FADE_OUT:
		if tween:
			tween.kill()
		
		tween = create_tween()
		var __ = tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		__ = tween.tween_method(self, "_set_mask_scale", zoomed_scale, dezoomed_scale, duration).set_delay(delay)
		
		yield(get_tree().create_timer(delay + duration * 0.5), "timeout")
	
	running = false
	EVENTS.emit_signal("transition_finished")


func _set_mask_scale(mask_scale: Vector2) -> void:
	var poly = PoolVector2Array()
	poly.resize(mask_poly.size())
	var center = GAME.window_size / 2.0
	
	for i in range(mask_poly.size()):
		poly[i] = (mask_poly[i] - center) * mask_scale + center
	
	for half in polygon_container.get_children():
		var screen_poly = half.get_node("Screen")
		var result_container = half.get_node("Result")
		
		var result_polygons = Geometry.clip_polygons_2d(screen_poly.polygon, poly)
		
		for result in result_container.get_children():
			var id = result.get_index()
			if id in range(result_polygons.size()):
				result.set_polygon(result_polygons[id])
			else:
				result.set_polygon(PoolVector2Array())
#
#		if result_polygons.empty():
#			if mask_scale < Vector2.ONE:
#				result = screen_poly.polygon
#		else:
#			result = result_polygons[0]
		
#		result_poly.set_polygon(result)
