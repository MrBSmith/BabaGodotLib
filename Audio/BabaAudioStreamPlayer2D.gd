tool
extends AudioStreamPlayer2D
class_name BabaAudioStreamPlayer2D

export(float, 0.0, 999.0) var pitch_range := 0.0

onready var start_pitch := pitch_scale

#### ACCESSORS ####

func is_class(value: String): return value == "BabaAudioStreamPlayer2D" or .is_class(value)
func get_class() -> String: return "BabaAudioStreamPlayer2D"


#### BUILT-IN ####

func _ready() -> void:
	pass

#### VIRTUALS ####



#### LOGIC ####

func play(from_position: float = 0.0) -> void:
	pitch_scale = start_pitch + rand_range(0.0, pitch_range) * Math.rand_sign()
	.play(from_position)



#### INPUTS ####



#### SIGNAL RESPONSES ####
