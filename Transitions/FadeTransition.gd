extends CanvasLayer
class_name FadeTransition

# This class can be used to make fade transitions (Fade in, fade out, or both)

enum FADE_MODE {FADE_IN_OUT, FADE_IN, FADE_OUT}

@export var start_color := Color.TRANSPARENT
@export var fade_color := Color.BLACK

var tween : Tween = null
var running : bool = false : get = is_running

#### ACCESSORS ####

func is_class(value: String): return value == "FadeTransition" or super.is_class(value)
func get_class() -> String: return "FadeTransition"

func set_visible(value: bool):
	$ColorRect.set_visible(value)
	visible = value

func is_running() -> bool: return running


#### BUILT-IN ####

func _ready() -> void:
	EVENTS.fade_transition.connect(_on_EVENTS_fade_transition)
	EVENTS.fade_transition_with_pause.connect(_on_EVENTS_fade_transition_with_pause)
	
	$ColorRect.set_anchors_preset(Control.PRESET_WIDE)
	$ColorRect.set_color(start_color)


#### VIRTUALS ####



#### LOGIC ####

func fade(fade_time: float = 1.0, fade_mode: int = FADE_MODE.FADE_IN_OUT, delay : float = 0.0, pause_time: float = 1.0) -> void:
	running = true
	var duration = fade_time / 2 if fade_mode == FADE_MODE.FADE_IN_OUT else fade_time
	
	var tween = create_tween()
	
	if fade_mode != FADE_MODE.FADE_IN:
		tween.set_ease(Tween.EASE_IN)
		tween.tween_property($ColorRect, "color:a", fade_color.a, duration).set_delay(delay)
		
		await tween.finished
		
		if fade_mode == FADE_MODE.FADE_IN_OUT:
			EVENTS.transition_middle.emit()
	
	if fade_mode == FADE_MODE.FADE_IN_OUT && pause_time > 0.0:
		await get_tree().create_timer(pause_time).timeout
		EVENTS.transition_pause_finished.emit()
	
	if fade_mode != FADE_MODE.FADE_OUT:
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property($ColorRect, "color:a",  0.0, duration).set_delay(delay)
		
		await tween.finished
	
	running = false
	EVENTS.transition_finished.emit()


func set_to_black() -> void:
	$ColorRect.set_color(Color.BLACK)


func set_to_transparent() -> void:
	$ColorRect.set_color(Color.TRANSPARENT)


#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_EVENTS_fade_transition(duration: float, fade_mode: int) -> void:
	fade(duration, fade_mode)


func _on_EVENTS_fade_transition_with_pause(duration: float, fade_mode: int, delay : float, pause_time: float) -> void:
	fade(duration, fade_mode, delay, pause_time)


func _on_EVENTS_interupt_transition() -> void:
	if tween != null:
		tween.kill()
	
	set_to_transparent()
