tool
extends AudioStreamPlayer2D
class_name BabaAudioStreamPlayer2D

enum PLAY_FLAG {
	AUTO_FADE = 1,
	RANDOM_POS = 2
}

export(int, FLAGS, "auto fade", "random pos") var play_flags : int = 0
export(float, 0.0, 999.0) var pitch_range := 0.0
export var sound_variations_array = []

export var auto_fade_duration : float = 1.0
export var delay := 0.0
export var loop := false
export var loop_delay := 0.0
export var print_logs: bool = false 

onready var sound_pool = sound_variations_array.duplicate()
onready var start_pitch := pitch_scale
onready var start_volume := volume_db


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
	
	# Random start position
	if from_position == 0.0 and play_flags & PLAY_FLAG.RANDOM_POS:
		from_position = rand_range(0.0, stream.get_length())
	
	# Auto fade
	if auto_fade_duration > 0.0 and play_flags & PLAY_FLAG.AUTO_FADE:
		var __ = fade()
	
	pitch_scale = start_pitch + rand_range(0.0, pitch_range) * Math.rand_sign()
	
	if !sound_variations_array.empty():
		sample_id = wrapi(sample_id + 1, 0, sound_variations_array.size())
		
		if sample_id == 0:
			sound_pool = sound_variations_array.duplicate()
			sound_pool.shuffle()
		
		set_stream(sound_pool[sample_id])
	
	running = true
	
	if print_logs: print("play")
	.play(from_position)


func stop() -> void:
	running = false
	
	if play_flags & PLAY_FLAG.AUTO_FADE:
		yield(fade(true), "finished")
	
	if print_logs: print("stop")
	.stop()


func fade(out: bool = false) -> SceneTreeTween:
	if print_logs:
		var sufix = "out" if out else "in" 
		print(name, " fade ", sufix)
	
	var tween = create_tween()
	var ease_type = Tween.EASE_IN if out else Tween.EASE_OUT
	var from = start_volume if out else -80.0
	var to = -80.0 if out else start_volume
	
	tween.set_ease(ease_type)
	tween.set_trans(Tween.TRANS_EXPO)
	
	set_volume_db(from)
	tween.tween_property(self, "volume_db", to, auto_fade_duration)
	
	return tween

#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_sound_finished() -> void:
	if loop: 
		if loop_delay > 0.0:
			yield(get_tree().create_timer(loop_delay), "timeout")
			if !running:
				return
		
		play()
