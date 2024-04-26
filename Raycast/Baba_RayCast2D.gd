extends RayCast2D
class_name Baba_RayCast2D

# Abstract class for a basic raycast, Searching for a specific target until it find it
# the signal target_found usually connected by it's parent is emitted whenever
# the first body found by the raycast is the target

signal target_found(target)

export var disable_on_target_found : bool = false
var cast_target : Node = null 


# Activate the ray cast, until it find a specific target
func search_for_target(target : Node):
	cast_target = target
	set_activate(target != null)


func set_activate(value: bool):
	set_enabled(value)
	set_physics_process(value)
	
	if value == false:
		cast_target = null


func _physics_process(_delta: float) -> void:
	if !enabled:
		return
	
	if is_instance_valid(cast_target):
		var dir = global_position.direction_to(cast_target.global_position)
		var dist = global_position.distance_to(cast_target.global_position)
		var relative_target_pos = dir * dist
		set_cast_to(relative_target_pos)
	
	var collider = get_collider()
	
	if collider != null:
		if cast_target != null and cast_target != collider:
			return
		
		emit_signal("target_found", collider)
		
		if disable_on_target_found:
			set_activate(false)
