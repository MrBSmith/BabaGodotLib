extends State
class_name Collectable_FollowState


#### ACCESSORS ####

func is_class(value: String): return value == "Collectable_FollowState" or .is_class(value)
func get_class() -> String: return "Collectable_FollowState"


#### BUILT-IN ####


#### VIRTUALS ####


func update_state(delta: float):
	var obj = owner.owner
	
	if !is_instance_valid(obj) or !obj.is_inside_tree():
		return
	
	if owner.target != null:
		owner.speed += owner.acceleration
		
		var obj_pos = obj.get_position()
		var target_pos = owner.target.get_position()
		var target_dir = obj_pos.direction_to(target_pos)
		var velocity = target_dir * owner.speed * delta
		
		if obj_pos.distance_to(target_pos) < owner.speed * delta:
			obj.set_position(target_pos)
		else:
			obj.set_position(obj_pos + velocity)

#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####
