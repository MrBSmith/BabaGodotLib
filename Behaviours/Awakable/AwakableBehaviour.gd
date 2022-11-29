extends Behaviour
class_name AwakableBehaviour

# This Behaviour should always be a child of a RigidBody2D
# It is usefull mainly in conjontion with an AwakerBehaviour

# It defines how a RigidBody2D can fall asleep or be awaken

signal woke
signal put_to_sleep

#### ACCESSORS ####

func is_class(value: String): return value == "AwakableBehaviour" or super.is_class(value)
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
	
	owner.set_mode(RigidBody2D.MODE_RIGID)
	
	owner.set_sleeping(false)
	owner.set_physics_process(true)
	
	woke.emit()


func asleep() -> void:
	if disabled:
		return

	if not owner is PhysicsBody2D && owner.get_mode() == RigidBody2D.FREEZE_MODE_STATIC:
		return

	if !owner.can_sleep:
		return

	owner.set_mode(RigidBody2D.MODE_RIGID)
	owner.set_sleeping(true)
	owner.set_physics_process(false)
	
	put_to_sleep.emit()


#### INPUTS ####



#### SIGNAL RESPONSES ####


