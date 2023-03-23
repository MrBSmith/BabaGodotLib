tool
extends AudioStreamPlayer2D
class_name BabaAudioStreamPlayer2D

export(float, 0.0, 999.0) var pitch_range := 0.0
export var sound_variations_array = []
onready var sound_pool = sound_variations_array.duplicate()

export var delay := 0.0
export var loop := false
export var loop_delay := 0.0

onready var start_pitch := pitch_scale

var sample_id : int = 0
var running := false

#### ACCESSORS ####

func is_class(value: String): return value == "BabaAudioStreamPlayer2D" or .is_class(value)
func get_class() -> String: return "BabaAudioStreamPlayer2D"


#### BUILT-IN ####

func _ready() -> void:
	var __ = connect("finished", self, "_on_sound_finished")
	sound_pool.shuffle()


#### VIRTUALS ####



#### LOGIC ####

func play(from_position: float = 0.0) -> void:
	if delay > 0.0:
		yield(get_tree().create_timer(delay), "timeout")
	
	pitch_scale = start_pitch + rand_range(0.0, pitch_range) * Math.rand_sign()
	
	if !sound_variations_array.empty():
		sample_id = wrapi(sample_id + 1, 0, sound_variations_array.size())
		
		if sample_id == 0:
			sound_pool = sound_variations_array.duplicate()
			sound_pool.shuffle()
		
		set_stream(sound_pool[sample_id])
	
	running = true
	
	.play(from_position)


func stop() -> void:
	running = false
	.stop()


#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_sound_finished() -> void:
	if loop: 
		if loop_delay > 0.0:
			yield(get_tree().create_timer(loop_delay), "timeout")
			if !running:
				return
		
		play()
