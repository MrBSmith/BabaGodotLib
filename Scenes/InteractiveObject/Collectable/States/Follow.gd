extends StateBase
class_name Collectable_FollowState

export var speed := 10.0
export var acceleration := 10.0
var start_speed := 0.0

#### ACCESSORS ####

func is_class(value: String): return value == "Collectable_FollowState" or .is_class(value)
func get_class() -> String: return "Collectable_FollowState"


#### BUILT-IN ####

func _ready() -> void:
	speed = start_speed


#### VIRTUALS ####

func enter_state():
	speed = start_speed


func update_state(delta: float):
	if owner.target != null:
		speed += acceleration
		
		var obj_pos = owner.get_position()
		var target_pos = owner.target.get_position()
		var target_dir = obj_pos.direction_to(target_pos)
		var velocity = target_dir * speed * delta
		
		if obj_pos.distance_to(target_pos) < speed * delta:
			owner.set_position(target_pos)
		else:
			owner.set_position(obj_pos + velocity)

#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####
