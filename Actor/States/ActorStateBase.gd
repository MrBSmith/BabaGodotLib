extends StateBase
class_name ActorStateBase

var animated_sprite : AnimatedSprite

#### BUILT-IN ####

func _ready() -> void:
	yield(owner, "ready")
	animated_sprite = owner.get_node_or_null("AnimatedSprite")


#### VIRTUALS ####

func update(_delta : float):
	pass


func enter_state():
	if animated_sprite == null:
		return
	
	var sprite_frames = animated_sprite.get_sprite_frames()
	if sprite_frames == null:
		return
	
	if sprite_frames.has_animation(name):
		animated_sprite.play(name)


func exit_state():
	pass
