extends Factory
class_name SoundEffectFactory

# This class is usefull to trigger sound that have to happen at the destruction of an object
# It takes a stream_player as an argument, duplicate it, play it and then destory it

#### ACCESSORS ####

func is_class(value: String): return value == "SoundEffectFactory" or .is_class(value)
func get_class() -> String: return "SoundEffectFactory"


#### BUILT-IN ####

func _ready() -> void:
	var __ = EVENTS.connect("play_sound_effect", self, "_on_EVENTS_play_sound_effect")


#### VIRTUALS ####



#### LOGIC ####

func play(stream_player : Node, pitch_range: float = 0.0) -> void:
	if stream_player == null:
		push_error("The given stream_player is null")
		return
	
	if not stream_player is AudioStreamPlayer and not stream_player is AudioStreamPlayer2D:
		push_error("the given stream_player doesn't have the right type. It has to be either an AudioStreamPlayer or a AudioStreamPlayer2D")
		return
	
	var new_stream_player = stream_player.duplicate()
	target.call_deferred("add_child", new_stream_player)
	
	if !new_stream_player.is_inside_tree():
		yield(new_stream_player, "ready")
	
	if stream_player is AudioStreamPlayer2D:
		var pos = stream_player.get_global_position()
		new_stream_player.set_global_position(pos)
	
	new_stream_player.pitch_scale += rand_range(0.0, pitch_range) * Math.rand_sign()
	new_stream_player.call_deferred("play")
	
	yield(new_stream_player, "finished")
	new_stream_player.queue_free()



#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_EVENTS_play_sound_effect(stream_player: Node, pitch_range: float = 0.0):
	if stream_player is AudioStreamPlayer or stream_player is AudioStreamPlayer2D:
		play(stream_player, pitch_range)
	else:
		push_warning("The given value is of type %s where it shouild be a AudioStreamPlayer or a AudioStreamPlayer2D" % stream_player.get_class())
