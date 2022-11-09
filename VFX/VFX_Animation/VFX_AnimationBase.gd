extends AnimatedSprite
class_name VFX_AnimationBase

var is_ready : bool = false

onready var start_offset = offset

func _ready():
	var _err = connect("animation_finished", self, "on_animation_finished")
	play_animation()
	
	is_ready = true

func play_animation():
	set_visible(true)
	play()
	$AudioStreamPlayer2D.play()


# OVERRIDE
func set_flip_h(value: bool) -> void:
	.set_flip_h(value)
	
	if is_ready:
		offset.x = start_offset.x * Math.bool_to_sign(!value)
	else:
		offset.x = abs(offset.x) * Math.bool_to_sign(!value)


func on_animation_finished():
	queue_free()
