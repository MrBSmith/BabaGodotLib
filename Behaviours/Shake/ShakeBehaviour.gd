extends Behaviour
class_name ShakeBehaviour

export var target_path : NodePath

onready var target = get_node_or_null(target_path)
onready var target_default_pos = target.position if target else Vector2.INF

var tween : SceneTreeTween

#### ACCESSORS ####

func is_class(value: String): return value == "ShakeBehaviour" or .is_class(value)
func get_class() -> String: return "ShakeBehaviour"

func is_shaking() -> bool: return is_instance_valid(tween)


#### BUILT-IN ####




#### VIRTUALS ####



#### LOGIC ####

func shake(magnitude: float = 8, duration: float = 1.0, jolts_per_sec : int = 12) -> void:
	if disabled:
		return
	
	if target == null:
		push_error("Cannot shake, target is null")
		return

	if not target is Node2D:
		push_error("Cannot shake target %s, it must inherit Node2D" % target.name)
		return
	
	var nb_jolts = int(jolts_per_sec * duration)
	var jolt_duration = duration / nb_jolts
	 
	tween = create_tween()
	
	for i in range(nb_jolts):
		var rdm_angle = deg2rad(rand_range(0.0, 360.0))
		var dir = Vector2.RIGHT.rotated(rdm_angle)
		var dest = target_default_pos + dir * magnitude if i != nb_jolts - 1 else target_default_pos 
		
		var __ = tween.tween_property(target, "position", dest, jolt_duration)


func kill() -> void:
	if is_instance_valid(tween):
		tween.kill()
	
	if target is Node2D:
		var return_tween = create_tween()
		
		return_tween.tween_property(target, "position", target_default_pos, 0.1)



#### INPUTS ####



#### SIGNAL RESPONSES ####
