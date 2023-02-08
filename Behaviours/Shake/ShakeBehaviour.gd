extends Behaviour
class_name ShakeBehaviour

enum {
	ROTATION = 1,
	POSITION = 2
}

export var target_path : NodePath

onready var target : Node2D = get_node_or_null(target_path) setget set_target

var target_default_pos := Vector2.INF
var target_default_rot := 0.0

var shaking : bool = false

var pos_tween : SceneTreeTween
var rot_tween : SceneTreeTween

#### ACCESSORS ####

func is_class(value: String): return value == "ShakeBehaviour" or .is_class(value)
func get_class() -> String: return "ShakeBehaviour"

func is_shaking() -> bool: return shaking

func set_target(value: Node2D) -> void:
	if value != target:
		target = value
		_update_target_default_values()

#### BUILT-IN ####


func _ready() -> void:
	if target:
		yield(get_tree(), "idle_frame")
		
		_update_target_default_values()



#### VIRTUALS ####



#### LOGIC ####


func _update_target_default_values() -> void:
	if target == null:
		return
	
	target_default_pos = target.position
	target_default_rot = target.rotation_degrees


func shake(magnitude: float = 8, duration: float = 1.0, jolts_per_sec : int = 12, flags = POSITION) -> void:
	if disabled or flags == 0:
		return
	
	if target == null:
		push_error("Cannot shake, target is null")
		return

	if not target is Node2D:
		push_error("Cannot shake target %s, it must inherit Node2D" % target.name)
		return
	
	shaking = true
	
	var nb_jolts = int(jolts_per_sec * duration)
	var jolt_duration = duration / nb_jolts
	
	if flags & POSITION: pos_tween = create_tween()
	if flags & ROTATION: rot_tween = create_tween()
	
	var rng = RandomNumberGenerator.new()

	for i in range(nb_jolts):
		if flags & POSITION:
			var rdm_angle = deg2rad(rand_range(0.0, 360.0))
			var dir = Vector2.RIGHT.rotated(rdm_angle)
			var dest = target_default_pos + dir * magnitude if i != nb_jolts - 1 else target_default_pos 
			
			var __ = pos_tween.tween_property(target, "position", dest, jolt_duration)
		
		if flags & ROTATION:
			var dir_sign = Math.bool_to_sign(i % 2 == 0) 
			var rot = target_default_rot + rng.randfn(magnitude, 3.0) * dir_sign
			
			var __ = rot_tween.tween_property(target, "rotation_degrees", rot, jolt_duration)
			

func kill() -> void:
	for tween in [pos_tween, rot_tween]:
		if is_instance_valid(tween):
			tween.kill()
	
	if target is Node2D:
		var return_tween = create_tween()
		var pos = target_default_pos
		
		if owner is Character:
			pos.x *= Math.bool_to_sign(!owner.facing_left)
		
		return_tween.tween_property(target, "position", pos, 0.2)
		return_tween.parallel().tween_property(target, "rotation_degrees", target_default_rot, 0.2)



#### INPUTS ####



#### SIGNAL RESPONSES ####
