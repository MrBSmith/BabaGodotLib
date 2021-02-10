extends RigidBody2D

func _ready():
	var _err = $AnimationPlayer.connect("animation_finished", self, "on_animation_finished")

func on_animation_finished(animation : String):
	if animation == "FadeOut":
		queue_free()
