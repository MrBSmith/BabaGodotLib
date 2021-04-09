extends ActorStateBase
class_name ActorFallState

#### BUILT-IN ####
func _ready():
	yield(owner, "ready")
	
	var _err = animated_sprite.connect("animation_finished", self, "on_animation_finished")


#### VIRTUALS ####

func update_state(_delta):
	if owner.is_on_floor():
		return "Idle"


#### SIGNAL RESPONSES ####

# Triggers the fall animation when the start falling is over
func on_animation_finished():
	if is_current_state():
		if animated_sprite.get_animation() == "StartFalling":
				animated_sprite.play(self.name)


