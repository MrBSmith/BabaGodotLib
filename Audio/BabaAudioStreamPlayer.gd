@tool
extends AudioStreamPlayer
class_name BabaAudioStreamPlayer

@export var pitch_range := 0.0 # (float, 0.0, 999.0)

@onready var start_pitch := pitch_scale

#### ACCESSORS ####


#### BUILT-IN ####



#### VIRTUALS ####



#### LOGIC ####

func play(from_position: float = 0.0) -> void:
	pitch_scale = start_pitch + randfn(1.0, pitch_range)
	super.play(from_position)



#### INPUTS ####



#### SIGNAL RESPONSES ####
