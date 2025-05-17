extends CanvasLayer
class_name Transition

enum MODE {
	IN,
	OUT,
	IN_OUT, 
}

var tween : Tween

var running : bool = false
var pause : bool = false:
	set(value):
		if value != pause:
			pause = value
			
			if pause:
				paused.emit()
			else:
				unpaused.emit()

#warning-ignore:unused_signal
signal started
signal paused
signal unpaused
#warning-ignore:unused_signal
signal transition_middle
#warning-ignore:unused_signal
signal transition_pause_finished
#warning-ignore:unused_signal
signal transition_finished


func trigger(_duration := 1.0, _mode: MODE = MODE.IN_OUT, _delay := 0.0, _pause_time := 1.0) -> void:
	pass


func interupt_transition() -> void:
	if tween:
		tween.kill()
	running = false
	
	transition_middle.emit()
	transition_finished.emit()
