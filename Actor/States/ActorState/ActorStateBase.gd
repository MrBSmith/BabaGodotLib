extends StateBase
class_name ActorStateBase

var animated_sprite : AnimatedSprite
onready var audio_stream_player := get_node_or_null("AudioStreamPlayer")

# If this bool is true, the state will return to the previous one whenever the animation is over
export var toggle_state : bool = false

#### BUILT-IN ####

func _ready() -> void:
	yield(owner, "ready")
	animated_sprite = owner.get_node_or_null("AnimatedSprite")

	if animated_sprite != null:
		var _err = animated_sprite.connect("animation_finished", self, "_on_animation_finished")

#### VIRTUALS ####

func update_state(_delta : float):
	pass


func enter_state():
	if audio_stream_player != null:
		audio_stream_player.play()
	
	if animated_sprite == null:
		return

	var sprite_frames = animated_sprite.get_sprite_frames()
	if sprite_frames == null:
		return

	if sprite_frames.has_animation("Start" + name):
		animated_sprite.play("Start" + name)

	else:
		if sprite_frames.has_animation(name):
			animated_sprite.play(name)


func exit_state():
	pass


#### SIGNAL RESPONSES #####

func _on_animation_finished():
	if states_machine.get_state() != self or !toggle_state or animated_sprite == null:
		return

	var sprite_frames = animated_sprite.get_sprite_frames()

	if animated_sprite.get_animation() == "Start" + name:
		if sprite_frames != null and sprite_frames.has_animation(name):
			animated_sprite.play(name)
	
	states_machine.set_state(states_machine.previous_state)
