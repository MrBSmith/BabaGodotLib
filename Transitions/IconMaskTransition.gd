extends TransitionLayer
class_name IconMaskTransition

const POLY_GEN_EPSILON = 1.5
const NB_LAYERS = 3
const LAYER_INTERVAL = 0.3

export var dezoomed_scale := Vector2(10.0, 10.0)
export var zoomed_scale := Vector2(0.5, 0.5)
export var level_type_textures_dict : Dictionary = {}

onready var pivot: Node2D = $"%Pivot"

var mask_poly_array : Array

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
	var mask_poly = bitmap.opaque_to_polygons(mask_rect, POLY_GEN_EPSILON)[0]
	var mask_offset = (GAME.window_size - image.get_size()) / 2.0
	
	for i in range(mask_poly.size()):
		mask_poly[i] += mask_offset
	
	mask_poly_array = []
	
	for i in range(NB_LAYERS):
		mask_poly_array.append(mask_poly)
	
	fade()
	
	yield(EVENTS, "transition_finished")
	yield(tween, "finished")
	
	hide()


func fade(fade_time := 2.0, fade_mode : int = FADE_MODE.FADE_IN_OUT, delay := 0.0, pause_time := 0.5) -> void:
	if tween:
		tween.kill()
	
	tween = create_tween()
	
	running = true
	var duration = fade_time / 2.0 if fade_mode == FADE_MODE.FADE_IN_OUT else fade_time
	
	if fade_mode != FADE_MODE.FADE_IN:
		for i in range(NB_LAYERS):
			var __ = tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			__ = tween.parallel().tween_method(self, "_set_mask_scale", dezoomed_scale, zoomed_scale, duration, [i]).set_delay(LAYER_INTERVAL * i + delay)
		
		yield(tween, "finished")
		
		if fade_mode == FADE_MODE.FADE_IN_OUT:
			EVENTS.emit_signal("transition_middle")
	
	if fade_mode == FADE_MODE.FADE_IN_OUT and pause_time > 0.0:
		yield(get_tree().create_timer(pause_time), "timeout")
		EVENTS.emit_signal("transition_pause_finished")
	
	if pause:
		yield(self, "unpaused")
	
	if fade_mode != FADE_MODE.FADE_OUT:
		if tween:
			tween.kill()
		
		tween = create_tween()
		for i in range(NB_LAYERS):
			var id = NB_LAYERS - i - 1
			var __ = tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
			__ = tween.parallel().tween_method(self, "_set_mask_scale", zoomed_scale, dezoomed_scale, duration, [id]).set_delay(LAYER_INTERVAL * i + delay)
		
		yield(tween, "finished")
	
	running = false
	EVENTS.emit_signal("transition_finished")


func _set_mask_scale(mask_scale: Vector2, mask_id: int) -> void:
	var poly = PoolVector2Array()
	poly.resize(mask_poly_array[mask_id].size())
	var center = GAME.window_size / 2.0
	
	for i in range(mask_poly_array[mask_id].size()):
		poly[i] = (mask_poly_array[mask_id][i] - center) * mask_scale + center
	
	var polygon_container: Node2D = $Layers.get_child(mask_id)
	
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
