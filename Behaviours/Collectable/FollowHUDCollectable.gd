extends FollowCollectable
class_name FollowHUDCollectable

export var camera_pos_relative : bool = true

#### ACCESSORS ####

func is_class(value: String): return value == "FollowHUDCollectable" or .is_class(value)
func get_class() -> String: return "FollowHUDCollectable"


#### BUILT-IN ####



#### VIRTUALS ####



#### LOGIC ####

func trigger_collect_animation() -> void:
	if collect_sound:
		EVENTS.emit_signal("play_sound_effect", collect_sound)
	
	if animation_player.has_animation("Collect"):
		animation_player.play("Collect")


#### INPUTS ####



#### SIGNAL RESPONSES ####
