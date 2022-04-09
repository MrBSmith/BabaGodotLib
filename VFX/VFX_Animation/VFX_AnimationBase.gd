extends AnimatedSprite
class_name VFX_AnimationBase

func _ready():
	var _err = connect("animation_finished", self, "on_animation_finished")
	play_animation()


func play_animation():
	set_visible(true)
	play()
	$AudioStreamPlayer2D.play()


func on_animation_finished():
	queue_free()
