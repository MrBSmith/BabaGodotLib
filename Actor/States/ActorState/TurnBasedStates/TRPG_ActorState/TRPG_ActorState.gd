extends State
class_name TRPG_ActorState

#### ACCESSORS ####

func is_class(value: String): return value == "TRPG_ActorState" or .is_class(value)
func get_class() -> String: return "TRPG_ActorState"


#### BUILT-IN ####

func _ready() -> void:
	var __ = owner.connect("changed_direction", self, "_on_actor_changed_direction")

#### VIRTUALS ####

func enter_state():
	update_actor_animation(owner.get_direction())


#### LOGIC ####

func _get_animation_name() -> String:
	var actor_dir = owner.get_direction()
	var bottom : bool = actor_dir in [IsoLogic.DIRECTION.BOTTOM_LEFT, IsoLogic.DIRECTION.BOTTOM_RIGHT]
	
	var sufix = "Bottom" if bottom else "Top"
	return name + sufix


func update_actor_animation(actor_dir: int):
	if animated_sprite == null:
		return
	
	var sprite_frames = animated_sprite.get_sprite_frames()
	if sprite_frames == null:
		return
	
	var animation_name = _get_animation_name()
	var right : bool = actor_dir in [IsoLogic.DIRECTION.TOP_RIGHT, IsoLogic.DIRECTION.BOTTOM_RIGHT]
	
	if sprite_frames.has_animation(animation_name):
		animated_sprite.play(animation_name)
	else:
		yield(get_tree().create_timer(1.0), "timeout")
		if is_current_state():
			states_machine.set_state(states_machine.previous_state)
	
	# Triggers the AnimationPlayer with the name of this state if one exists 
	var animation_player : AnimationPlayer = owner.get("animation_player")
	if animation_player != null && animation_player.has_animation(name):
		animation_player.play(name)
	
	# Flip the animations accordingly
	owner.set_flip_h_SFX(!right)
	animated_sprite.set_flip_h(!right)


#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_actor_changed_direction(dir: int):
	if !is_current_state():
		 return
	
	update_actor_animation(dir)


