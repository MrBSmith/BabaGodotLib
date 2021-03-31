extends StateBase
class_name Collectable_CollectState

export var speed : float = 300.0
export var acceleration : float = 3.0

var initial_dir = Vector2.ZERO
export var initial_speed = 1000.0
export var initial_speed_damping = 200.0

var target : Node2D = null setget set_target, get_target

#### ACCESSORS ####

func is_class(value: String): return value == "CollectState" or .is_class(value)
func get_class() -> String: return "CollectState"

func set_target(value: Node2D): target = value
func get_target() -> Node2D: return target

#### BUILT-IN ####



#### VIRTUALS ####

func enter_state():
	owner.set_interactable(false)
	owner.set_scale(owner.get_scale() / 3)
	owner.set_as_toplevel(true)
	var rdm_angle = deg2rad(rand_range(0.0, 360.0))
	initial_dir = Vector2(cos(rdm_angle), sin(rdm_angle))
	
	if owner.collect_particle != null:
		owner.collect_particle.set_emitting(true)


func exit_state():
	pass


func update_state(delta: float):
	var target_pos = target.get_global_position()
	var dir = owner.global_position.direction_to(target_pos)
	var velocity = ((dir * speed) + (initial_dir * initial_speed)) * delta
	
	speed += acceleration
	initial_speed -= initial_speed_damping
	initial_speed = clamp(initial_speed, 0.0, INF)
	
	if owner.global_position.distance_to(target_pos) < speed * delta:
		owner.set_global_position(target_pos)
		owner.emit_signal("collect_animation_finished")
	
	owner.global_position += velocity


#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####
