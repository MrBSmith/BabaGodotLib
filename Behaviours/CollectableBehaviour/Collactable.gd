extends CollectableBehaviour
class_name Collectable


#### ACCESSORS ####

func is_class(value: String): return value == "Collectable" or .is_class(value)
func get_class() -> String: return "Collectable"


#### BUILT-IN ####



#### VIRTUALS ####



#### LOGIC ####

func collect() -> void:
	set_target(null)
	set_state("Collect")
	set_interactable(false)
	EVENTS.emit_signal("collect", owner, collectable_name)
	
	trigger_collect_animation()


func trigger_collect_animation() -> void:
	if animation_player.has_animation("Collect"):
		animation_player.play("Collect")
	else:
		_collect_success()


func compute_amount_collected() -> int:
	return int(average_amount * (1 + rand_range(-amount_variance, amount_variance)))


func _collect_success() -> void:
	EVENTS.emit_signal("collectable_amount_collected", collectable_name, compute_amount_collected())
	owner.queue_free()


#### INPUTS ####



#### SIGNAL RESPONSES ####


func _on_collect_area_body_entered(body: PhysicsBody2D):
	if body == null:
		return
	
	if body.is_class("Player"):
		collect()


func _on_collect_animation_finished() -> void:
	_collect_success()

