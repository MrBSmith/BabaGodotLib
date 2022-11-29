@tool
extends AudioStreamPlayer
class_name BabaAudioStreamPlayer

@export var pitch_range := 0.0 # (float, 0.0, 999.0)

@onready var start_pitch := pitch_scale

#### ACCESSORS ####

func is_class(value: String): return value == "BabaAudioStreamPlayer" or super.is_class(value)
func get_class() -> String: return "BabaAudioStreamPlayer"


#### BUILT-IN ####

func _ready() -> void:
	pass

#### VIRTUALS ####



#### LOGIC ####

func play(from_position: float = 0.0) -> void:
	pitch_scale = start_pitch + randf_range(0.0, pitch_range) * Math.rand_sign()
	super.play(from_position)



#### INPUTS ####



#### SIGNAL RESPONSES ####
