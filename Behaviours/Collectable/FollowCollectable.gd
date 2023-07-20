extends CollectableBehaviour
class_name FollowCollectable

onready var state_machine = get_node("StateMachine")
onready var raycast = get_node_or_null("Baba_RayCast2D")

export var default_state : String = ""

var speed := 0.0
export var acceleration := 10.0

#### ACCESSORS ####

func is_class(value: String): return value == "FollowCollectable" or .is_class(value)
func get_class() -> String: return "FollowCollectable"

func set_state(state): state_machine.set_state(state)
func get_state() -> Object: return state_machine.get_state()
func get_state_name(): return state_machine.get_state_name()

#### BUILT-IN ####

func _ready() -> void:
	var __ = $FollowArea.connect("body_entered", self, "_on_follow_area_body_entered")
	__ = $FollowArea.connect("body_exited", self, "_on_follow_area_body_exited")
	
	if raycast:
		raycast.connect("target_found", self, "_on_raycast_target_found")

#### VIRTUALS ####



#### LOGIC ####

func collect() -> void:
	if is_disabled():
		return
	
	set_state("Collect")
	
	set_target(null)
	EVENTS.emit_signal("collect", owner, get_collectable_name())
	EVENTS.emit_signal("play_VFX", collect_VFX_name, owner.get_global_position())
	
	if collect_sound:
		EVENTS.emit_signal("play_sound_effect", collect_sound)
	
	trigger_collect_animation()
	.collect()


func follow_target(new_target: Node):
	if $AnimationPlayer.has_animation("Follow"):
		$AnimationPlayer.play("Follow")
	
	set_target(new_target)
	set_state("Follow")


func trigger_collect_animation() -> void:
	if animation_player.has_animation("Collect"):
		animation_player.play("Collect")
	else:
		_collect_success()


func compute_amount_collected() -> int:
	return int(average_amount * (1 + rand_range(-amount_variance, amount_variance)))


remotesync func _collect_success() -> void:
	EVENTS.emit_signal("increment_collectable_amount", get_collectable_name(), compute_amount_collected())
	owner.queue_free()


#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_follow_area_body_entered(body: Node):
	if is_disabled():
		return
	
	if raycast != null:
		raycast.search_for_target(body)
	else:
		follow_target(body)


func _on_follow_area_body_exited(_body: Node):
	if $FollowArea.get_overlapping_bodies().empty():
		raycast.set_enabled(false)


func _on_raycast_target_found(target: Node) -> void:
	follow_target(target)
	raycast.set_enabled(false)


func _on_collect_area_body_entered(body: PhysicsBody2D):
	if body == null or is_disabled():
		return
	
	if body.is_class("Player") or body.is_class("Character"):
		collect()


func _on_collect_animation_finished() -> void:
	NETWORK.rpc_or_direct_call(self, "_collect_success")


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "Collect":
		emit_signal("collect_animation_finished")
