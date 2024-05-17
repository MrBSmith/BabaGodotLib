extends Timer
class_name RangeTimer

onready var average_wait_time := wait_time
export(float, 0.0, 99.0) var wait_time_variance := 1.0


func _ready() -> void:
	var __ = connect("timeout", self, "_on_timeout")


func start(time_sec := -1.0) -> void:
	if time_sec == -1.0:
		var variance = rand_range(-wait_time_variance, wait_time_variance)
		time_sec = clamp(average_wait_time + variance, 0.01, average_wait_time + wait_time_variance)
	
	.start(time_sec)


func _on_timeout() -> void:
	if !one_shot:
		start()
