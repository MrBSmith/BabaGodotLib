extends TransitionLayer
class_name FadeTransition

export var start_color := Color.transparent
export var fade_color := Color.black
onready var color_rect: ColorRect = $ColorRect


#### ACCESSORS ####

func is_class(value: String): return value == "FadeTransition" or .is_class(value)
func get_class() -> String: return "FadeTransition"

func set_visible(value: bool):
	color_rect.set_visible(value)


#### BUILT-IN ####

func _ready() -> void:
	var __ = EVENTS.connect("fade_transition", self, "_on_EVENTS_fade_transition")
	__ = EVENTS.connect("fade_transition_with_pause", self, "_on_EVENTS_fade_transition_with_pause")
	
	color_rect.set_anchors_preset(Control.PRESET_WIDE)
	color_rect.set_frame_color(start_color)


#### VIRTUALS ####



#### LOGIC ####

func fade(fade_time: float = 1.0, fade_mode: int = FADE_MODE.FADE_IN_OUT, delay : float = 0.0, pause_time: float = 1.0) -> void:
	if tween:
		tween.kill()
	
	tween = create_tween()
	
	running = true
	var duration = fade_time / 2 if fade_mode == FADE_MODE.FADE_IN_OUT else fade_time
	
	if fade_mode != FADE_MODE.FADE_IN:
		color_rect.color = Color(0.0, 0.0, 0.0, 0.0)
		var __ = tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
		__ = tween.tween_property(color_rect, "color", fade_color, duration).set_delay(delay)
		
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
		
		color_rect.color = fade_color
		var __ = tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
		__ = tween.tween_property(color_rect, "color", Color(0.0, 0.0, 0.0, 0.0), duration).set_delay(delay)
		
		yield(tween, "finished")
	
	running = false
	EVENTS.emit_signal("transition_finished")


func interupt_transition() -> void:
	.interupt_transition()
	set_to_transparent()


func set_to_black() -> void:
	color_rect.set_frame_color(Color.black)


func set_to_transparent() -> void:
	color_rect.set_frame_color(Color.transparent)


#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_EVENTS_fade_transition(duration: float, fade_mode: int) -> void:
	fade(duration, fade_mode)


func _on_EVENTS_fade_transition_with_pause(duration: float, fade_mode: int, delay : float, pause_time: float) -> void:
	fade(duration, fade_mode, delay, pause_time)


func _on_EVENTS_interupt_transition() -> void:
	interupt_transition()
