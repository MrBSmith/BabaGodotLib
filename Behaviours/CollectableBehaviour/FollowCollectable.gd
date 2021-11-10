extends Collectable
class_name FollowCollectable

var speed := 0.0
export var acceleration := 10.0

#### ACCESSORS ####

func is_class(value: String): return value == "FollowCollectable" or .is_class(value)
func get_class() -> String: return "FollowCollectable"



#### BUILT-IN ####

func _ready() -> void:
	var __ = $FollowArea.connect("body_entered", self, "_on_follow_area_body_entered")



func _physics_process(delta: float) -> void:
	match(get_state_name()):
		"Idle":
			pass
		"Follow":
			follow(delta)
		"Collect":
			pass



#### VIRTUALS ####



#### LOGIC ####

func follow_target(new_target: Node):
	set_target(new_target)
	set_state("Follow")


func follow(delta: float) -> void:
	if target != null:
		speed += acceleration
		
		var obj_pos = owner.get_position()
		var target_pos = target.get_position()
		var target_dir = obj_pos.direction_to(target_pos)
		var velocity = target_dir * speed * delta
		
		if obj_pos.distance_to(target_pos) < speed * delta:
			owner.set_position(target_pos)
		else:
			owner.set_position(obj_pos + velocity)


#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_follow_area_body_entered(body: Node):
	if body.is_class("Player"):
		follow_target(body)


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	_collect_success()
