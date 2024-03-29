extends Behaviour
class_name AwakableBehaviour

# This Behaviour should always be a child of a RigidBody2D
# It is usefull mainly in conjontion with an AwakerBehaviour

# It defines how a RigidBody2D can fall asleep or be awaken

signal awake
signal asleep

#### ACCESSORS ####

func is_class(value: String): return value == "AwakableBehaviour" or .is_class(value)
func get_class() -> String: return "AwakableBehaviour"


#### BUILT-IN ####



#### VIRTUALS ####



#### LOGIC ####

# Awake this instance, generaly called by a surrounding body when destoyed
func awake() -> void:
	if disabled:
		return
	
	if not owner is PhysicsBody2D:
		return
	
	owner.call_deferred("set_mode", RigidBody2D.MODE_RIGID)
	owner.call_deferred("set_sleeping", false)
	owner.call_deferred("set_physics_process", true)
	
	emit_signal("awake")


func asleep() -> void:
	if disabled:
		return

	if not owner is PhysicsBody2D && owner.get_mode() == RigidBody2D.MODE_STATIC:
		return

	if !owner.can_sleep:
		return

	owner.call_deferred("set_mode", RigidBody2D.MODE_STATIC)
	owner.call_deferred("set_sleeping", true)
	owner.call_deferred("set_physics_process", false)
	
	emit_signal("asleep")


#### INPUTS ####



#### SIGNAL RESPONSES ####


