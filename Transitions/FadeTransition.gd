extends Transition
class_name FadeTransition

@export var start_color := Color.TRANSPARENT
@export var fade_color := Color.BLACK
@export var color_rect: ColorRect


#### BUILT-IN ####

func _ready() -> void:
	color_rect.set_frame_color(start_color)


#### VIRTUALS ####



#### LOGIC ####

func trigger(duration := 1.0, mode: MODE = MODE.IN_OUT, delay := 0.0, pause_time := 1.0) -> void:
	started.emit()
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	
	running = true
	var dur = duration / 2 if mode == MODE.IN_OUT else duration
	
	if mode != MODE.IN:
		color_rect.color = Color(0.0, 0.0, 0.0, 0.0)
		var __ = tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
		__ = tween.tween_property(color_rect, "color", fade_color, duration).set_delay(delay)
		
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
		
		color_rect.color = fade_color
		var __ = tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
		__ = tween.tween_property(color_rect, "color", Color(0.0, 0.0, 0.0, 0.0), duration).set_delay(delay)
		
		await tween.finished
	
	running = false
	transition_finished.emit()


func interupt_transition() -> void:
	super.interupt_transition()
	set_to_transparent()


func set_to_black() -> void:
	color_rect.set_frame_color(Color.BLACK)


func set_to_transparent() -> void:
	color_rect.set_frame_color(Color.TRANSPARENT)


#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_EVENTS_interupt_transition() -> void:
	interupt_transition()
