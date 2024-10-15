extends TransitionLayer
class_name IconMaskTransition

export var dezoomed_scale := Vector2(10.0, 10.0)
export var zoomed_scale := Vector2(0.01, 0.01)
export var level_type_textures_dict : Dictionary = {}

onready var pivot: Node2D = $"%Pivot"
onready var mask: TextureRect = $"%Mask"


func _ready() -> void:
	var __ = EVENTS.connect("level_transition", self, "_trigger")
	hide()



func _trigger(level_type: String) -> void:
	var texture = level_type_textures_dict.get(level_type)
	
	if texture == null:
		push_error("Texture of type %s not found" % level_type)
		return
	
	show()
	mask.set_texture(texture)
	fade()
	
	yield(EVENTS, "transition_finished")
	hide()


func fade(fade_time := 3.0, fade_mode : int = FADE_MODE.FADE_IN_OUT, delay := 0.0, pause_time := 1.0) -> void:
	if tween:
		tween.kill()
	
	tween = create_tween()
	
	running = true
	var duration = fade_time / 2.0 if fade_mode == FADE_MODE.FADE_IN_OUT else fade_time
	
	if fade_mode != FADE_MODE.FADE_IN:
		pivot.set_scale(dezoomed_scale)
		var __ = tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		__ = tween.tween_property(pivot, "scale", zoomed_scale, duration).set_delay(delay)
		
		yield(tween, "finished")
		mask.hide()
		
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
		mask.show()
		pivot.set_scale(zoomed_scale)
		var __ = tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		__ = tween.tween_property(pivot, "scale", dezoomed_scale, duration).set_delay(delay)
		
		yield(get_tree().create_timer(delay + duration * 0.5), "timeout")
	
	running = false
	EVENTS.emit_signal("transition_finished")



