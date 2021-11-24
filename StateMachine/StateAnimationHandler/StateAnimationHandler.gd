extends Node
class_name StateAnimationHandler

export var animated_sprite_path : NodePath
onready var animated_sprite : AnimatedSprite = get_node(animated_sprite_path)
onready var states_machine = get_parent()


#### ACCESSORS ####

func is_class(value: String): return value == "StateAnimationHandler" or .is_class(value)
func get_class() -> String: return "StateAnimationHandler"


#### BUILT-IN ####

func _ready() -> void:
	yield(owner, "ready")
	
	var __ = get_parent().connect("state_changed", self, "_on_StatesMachine_state_changed")
	__ = animated_sprite.connect("animation_finished", self, "_on_animation_finished")

#### VIRTUALS ####


func _update_animation(state: Node):
	var audio_stream_player = state.get_node_or_null("AudioStreamPlayer")
	var state_name = state.name
	
	if audio_stream_player != null:
		audio_stream_player.stop()
		audio_stream_player.play()
	
	if animated_sprite == null:
		return

	var sprite_frames = animated_sprite.get_sprite_frames()
	if sprite_frames == null:
		return

	if sprite_frames.has_animation("Start" + state_name):
		animated_sprite.play("Start" + state_name)

	else:
		if sprite_frames.has_animation(state_name):
			animated_sprite.play(state_name)



#### SIGNAL RESPONSES #####

func _on_animation_finished():
	if animated_sprite == null:
		return
	
	var state = get_parent().get_state()
	var current_state_name = state.name
	
	var sprite_frames = animated_sprite.get_sprite_frames()
	var current_animation = animated_sprite.get_animation()
	
	if !current_state_name.is_subsequence_ofi(current_animation):
		return
	
	if !"Start".is_subsequence_ofi(current_animation):
		if state.toggle_state_mode:
			state.exit_toggle_state()
	
	if current_animation == "Start" + current_state_name:
		if sprite_frames != null and sprite_frames.has_animation(current_state_name):
			animated_sprite.play(current_state_name)



func _on_StatesMachine_state_changed(new_state: Node) -> void:
	_update_animation(new_state)
