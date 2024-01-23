extends AnimatedSprite
class_name VFX_AnimationBase

onready var start_offset = offset
onready var anim_player = get_node_or_null("AnimationPlayer")
onready var on_screen_rect = get_node_or_null("OnScreenRect")

export var debug := false
export var default_anim_name := "default"

var is_ready : bool = false

func _ready():
	if anim_player:
		var _err = anim_player.connect("animation_finished", self, "on_animation_finished")
	else:
		var _err = connect("animation_finished", self, "on_animation_finished", [default_anim_name])
	
	if !debug:
		play_animation()
	
	is_ready = true


func play_animation():
	if anim_player:
		anim_player.play(default_anim_name)
	else:
		set_visible(true)
		play(default_anim_name)
		$AudioStreamPlayer2D.play()


func _unhandled_input(_event: InputEvent) -> void:
	if !debug:
		return
	
	if Input.is_action_pressed("ui_accept"):
		play_animation()


# OVERRIDE
func set_flip_h(value: bool) -> void:
	.set_flip_h(value)
	
	if is_ready:
		offset.x = start_offset.x * Math.bool_to_sign(!value)
	else:
		offset.x = abs(offset.x) * Math.bool_to_sign(!value)


func on_animation_finished(_anim_name: String) -> void:
	queue_free()
