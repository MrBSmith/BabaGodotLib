extends Trait
class_name ShakeTrait

enum {
	ROTATION = 1,
	POSITION = 2
}

@export var target : Node
@export var rot_deviation := 3.0
@export var disabled := false
@export_flags("rotation", "position") var shake_mode_flags = ROTATION | POSITION

var target_default_pos := Vector2.INF
var target_default_rot := 0.0

var shaking : bool = false

var pos_tween : Tween
var rot_tween : Tween

signal started
signal stopped

#### ACCESSORS ####

func is_shaking() -> bool: return shaking

func set_target(value: Node2D) -> void:
	if value != target:
		assert(target is Node2D or target is Control, "The target of a ShakeBehaviour must inherit Node2D or Control")
		
		target = value
		_update_target_default_values()

#### BUILT-IN ####


func _ready() -> void:
	if target:
		await get_tree().process_frame
		
		_update_target_default_values()



#### VIRTUALS ####



#### LOGIC ####


func _update_target_default_values() -> void:
	if target == null:
		return
	
	target_default_pos = target.position
	target_default_rot = target.rotation_degrees


func shake(magnitude: float = 8, duration: float = 1.0, jolts_per_sec : int = 12, flags = shake_mode_flags, discreate: bool = false) -> void:
	if disabled or flags == 0:
		return
	
	if target == null:
		push_error("Cannot shake, target is null")
		return
	
	kill(false, true)
	
	shaking = true
	var dur = duration if duration != INF else 1.0
	
	var nb_jolts = int(jolts_per_sec * dur)
	var jolt_duration = dur / float(nb_jolts)
	
	if flags & POSITION: pos_tween = create_tween()
	if flags & ROTATION: rot_tween = create_tween()
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	for i in range(nb_jolts):
		if flags & POSITION:
			var rdm_angle = deg_to_rad(randf_range(0.0, 360.0))
			var dir = Vector2.RIGHT.rotated(rdm_angle)
			var dest = target_default_pos + dir * magnitude if i != nb_jolts - 1 else target_default_pos 
			
			var __ = pos_tween.tween_property(target, "position", dest, jolt_duration)
		
		if flags & ROTATION:
			var dir_sign = Maths.bool_to_sign(i % 2 == 0) 
			var rot = target_default_rot + rng.randfn(magnitude, rot_deviation) * dir_sign
			var dest_rot = rot if i != nb_jolts - 1 else target_default_rot
			
			var __ = rot_tween.tween_property(target, "rotation_degrees", dest_rot, jolt_duration)
	
	if duration == INF:
		for tween in [pos_tween, rot_tween]:
			if tween:
				tween.finished.connect(_on_infinite_shake_tween_finished, [magnitude, jolts_per_sec, flags])
	
	if !discreate:
		started.emit()


func kill(return_to_default_state: bool = true, discreate: bool = false) -> void:
	if !is_inside_tree():
		return
	
	for tween in [pos_tween, rot_tween]:
		if is_instance_valid(tween):
			tween.kill()
	
	if return_to_default_state and target is Node2D:
		var return_tween = create_tween()
		var pos = target_default_pos
		
		return_tween.tween_property(target, "position", pos, 0.2)
		return_tween.parallel().tween_property(target, "rotation_degrees", target_default_rot, 0.2)
	
	if !discreate:
		stopped.emit()


#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_infinite_shake_tween_finished(magnitude: float, jolts_per_sec : int, flags: int) -> void:
	kill(false, true)
	shake(magnitude, INF, jolts_per_sec, flags, true)
