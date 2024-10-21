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
	
	var target = owner.get_target()
	
	if target != null:
		owner.speed += owner.acceleration
		
		var obj_pos = obj.get_global_position()
		var target_pos = target.get_global_position()
		
		if obj_pos.distance_to(target_pos) < owner.speed * delta:
			obj.set_global_position(target_pos)
		else:
			obj.set_global_position(obj_pos.move_toward(target_pos, owner.speed * delta))


#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####
