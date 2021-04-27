extends Node2D
class_name SoundEffectsHandler

# This class is usefull to trigger sound that have to happen at the destruction of an object
# It takes a stream_player as an argument, duplicate it, play it and then destory it

#### ACCESSORS ####

func is_class(value: String): return value == "SoundEffectsHandler" or .is_class(value)
func get_class() -> String: return "SoundEffectsHandler"


#### BUILT-IN ####

func _ready() -> void:
	var __ = EVENTS.connect("play_sound_effect", self, "_on_play_sound_effect")

#### VIRTUALS ####



#### LOGIC ####

func play(stream_player : Node):
	if stream_player == null:
		push_error("The given stream_player is null")
		return
	
	if not stream_player is AudioStreamPlayer and not stream_player is AudioStreamPlayer2D:
		push_error("the given stream_player doesn't have the right type. It has to be either an AudioStreamPlayer or a AudioStreamPlayer2D")
		return
	
	var new_stream_player = stream_player.duplicate()
	call_deferred("add_child", new_stream_player)
	new_stream_player.call_deferred("play")
	
	yield(new_stream_player, "finished")
	new_stream_player.queue_free()


#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_play_sound_effect(stream_player: AudioStreamPlayer):
	play(stream_player)
