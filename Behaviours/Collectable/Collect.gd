extends State
class_name Collectable_CollectState

onready var root_scene = owner.owner

export var speed : float = 600.0
export var acceleration : float = 3.0

var initial_dir = Vector2.ZERO
export var initial_speed = 1000.0
export var initial_speed_damping = 200.0

#### ACCESSORS ####

func is_class(value: String): return value == "CollectState" or .is_class(value)
func get_class() -> String: return "CollectState"


#### BUILT-IN ####



#### VIRTUALS ####

func enter_state():
	root_scene.set_z_index(999)
	owner.set_disabled(true)
	root_scene.set_scale(root_scene.get_scale() / 3)
	var rdm_angle = deg2rad(rand_range(0.0, 360.0))
	initial_dir = Vector2(cos(rdm_angle), sin(rdm_angle))


func exit_state():
	pass


func update_state(delta: float):
	if owner.get_target() == null:
		return
	
	var target = owner.get_target()
	var target_global_pos = target.get_global_position()
	var camera = get_current_camera2D()
	var camera_top_left_corner = camera.get_camera_screen_center() - GAME.window_size / 2
	var target_pos = camera_top_left_corner + target_global_pos
	
	if target.get("rect_pivot_offset"):
		target_pos += target.rect_pivot_offset
	
	var dir = root_scene.position.direction_to(target_pos)
	
	speed += acceleration
	initial_speed -= initial_speed_damping
	initial_speed = clamp(initial_speed, 0.0, INF)
	
	var velocity = ((dir * speed) + (initial_dir * initial_speed))  * delta
	var dist = root_scene.global_position.distance_to(target_pos)
	var vel_len = velocity.length()
	
	if dist <= vel_len:
		root_scene.set_global_position(target_pos)
		owner.emit_signal("collect_animation_finished")
	else:
		root_scene.global_position += velocity


func get_current_camera2D() -> Camera2D:
	var viewport = get_viewport()
	if not viewport:
		return null
	var camerasGroupName = "__cameras_%d" % viewport.get_viewport_rid().get_id()
	var cameras = get_tree().get_nodes_in_group(camerasGroupName)
	for camera in cameras:
		if camera is Camera2D and camera.current:
			return camera
	return null

#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####
