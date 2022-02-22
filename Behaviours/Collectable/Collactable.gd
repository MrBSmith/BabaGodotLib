extends CollectableBehaviour
class_name Collectable


#### ACCESSORS ####

func is_class(value: String): return value == "Collectable" or .is_class(value)
func get_class() -> String: return "Collectable"


#### BUILT-IN ####




#### VIRTUALS ####



#### LOGIC ####

func collect() -> void:
	if is_disabled():
		return
	
	set_target(null)
	EVENTS.emit_signal("collect", self, get_collectable_name())
	
	trigger_collect_animation()


func trigger_collect_animation() -> void:
	if collect_sound:
		EVENTS.emit_signal("play_spacial_sound_effect", collect_sound, owner.get_global_position())
	
	if animation_player.has_animation("Collect"):
		animation_player.play("Collect")
	else:
		_collect_success()


func compute_amount_collected() -> int:
	return int(average_amount * (1 + rand_range(-amount_variance, amount_variance)))


func _collect_success() -> void:
	EVENTS.emit_signal("collectable_amount_collected", get_collectable_name(), compute_amount_collected())
	owner.queue_free()


#### INPUTS ####



#### SIGNAL RESPONSES ####


func _on_collect_area_body_entered(body: PhysicsBody2D):
	if body == null or is_disabled():
		return
	
	if body.is_class("Player") or body.is_class("Character"):
		collect()


func _on_collect_animation_finished() -> void:
	_collect_success()


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "Collect":
		emit_signal("collect_animation_finished")
