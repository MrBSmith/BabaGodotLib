extends StateBase
class_name AnimatedObjectStateBase

var animated_sprite : AnimatedSprite
onready var audio_stream_player := get_node_or_null("AudioStreamPlayer")

# If this variable is true, the state will return to the 
# previous one whenever the animation is finished
export var toggle_state_mode : bool = false

signal state_animation_finished()

#### ACCESSORS ####

func is_class(value: String): return value == "AnimatedObjectStateBase" or .is_class(value)
func get_class() -> String: return "AnimatedObjectStateBase"


#### BUILT-IN ####

func _ready() -> void:
	yield(owner, "ready")
	animated_sprite = owner.get_node_or_null("AnimatedSprite")

	if animated_sprite != null:
		var _err = animated_sprite.connect("animation_finished", self, "_on_animation_finished")

#### VIRTUALS ####


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
	if !is_current_state() or animated_sprite == null:
		return
	
	var sprite_frames = animated_sprite.get_sprite_frames()
	var current_animation = animated_sprite.get_animation()
	
	if !"Start".is_subsequence_ofi(current_animation):
		emit_signal("state_animation_finished")
	
	if !toggle_state_mode or !name.is_subsequence_ofi(current_animation):
		return
	
	if current_animation == "Start" + name:
		if sprite_frames != null and sprite_frames.has_animation(name):
			animated_sprite.play(name)
	else:
		states_machine.set_state(states_machine.previous_state)
