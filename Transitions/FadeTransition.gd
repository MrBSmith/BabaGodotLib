extends TransitionLayer
class_name FadeTransition

# This class can be used to make fade transitions (Fade in, fade out, or both)

enum FADE_MODE {FADE_IN_OUT, FADE_IN, FADE_OUT}

onready var tween = $Tween

export var start_color := Color.transparent
export var fade_color := Color.black


#### ACCESSORS ####

func is_class(value: String): return value == "FadeTransition" or .is_class(value)
func get_class() -> String: return "FadeTransition"

func set_visible(value: bool):
	$ColorRect.set_visible(value)


#### BUILT-IN ####

func _ready() -> void:
	var __ = EVENTS.connect("fade_transition", self, "_on_EVENTS_fade_transition")
	__ = EVENTS.connect("fade_transition_with_pause", self, "_on_EVENTS_fade_transition_with_pause")
	
	$ColorRect.set_anchors_preset(Control.PRESET_WIDE)
	$ColorRect.set_frame_color(start_color)


#### VIRTUALS ####



#### LOGIC ####

func fade(fade_time: float = 1.0, fade_mode: int = FADE_MODE.FADE_IN_OUT, delay : float = 0.0, pause_time: float = 1.0) -> void:
	running = true
	var duration = fade_time / 2 if fade_mode == FADE_MODE.FADE_IN_OUT else fade_time
	
	if fade_mode != FADE_MODE.FADE_IN:
		tween.interpolate_property($ColorRect, "color", Color(0.0, 0.0, 0.0, 0.0), fade_color,
					 duration, Tween.TRANS_LINEAR, Tween.EASE_IN, delay)
		
		tween.start()
		yield(tween, "tween_all_completed")
		
		if fade_mode == FADE_MODE.FADE_IN_OUT:
			EVENTS.emit_signal("transition_middle")
	
	if fade_mode == FADE_MODE.FADE_IN_OUT && pause_time > 0.0:
		yield(get_tree().create_timer(pause_time), "timeout")
		EVENTS.emit_signal("transition_pause_finished")
	
	if fade_mode != FADE_MODE.FADE_OUT:
		tween.interpolate_property($ColorRect, "color", fade_color, Color(0.0, 0.0, 0.0, 0.0),
					 duration, Tween.TRANS_LINEAR, Tween.EASE_OUT, delay)
		
		tween.start()
		yield(tween, "tween_all_completed")
	
	running = false
	EVENTS.emit_signal("transition_finished")


func interupt_transition() -> void:
	tween.stop_all()
	tween.remove_all()
	running = false
	set_to_transparent()


func set_to_black() -> void:
	$ColorRect.set_frame_color(Color.black)


func set_to_transparent() -> void:
	$ColorRect.set_frame_color(Color.transparent)


#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_EVENTS_fade_transition(duration: float, fade_mode: int) -> void:
	fade(duration, fade_mode)


func _on_EVENTS_fade_transition_with_pause(duration: float, fade_mode: int, delay : float, pause_time: float) -> void:
	fade(duration, fade_mode, delay, pause_time)


func _on_EVENTS_interupt_transition() -> void:
	interupt_transition()
