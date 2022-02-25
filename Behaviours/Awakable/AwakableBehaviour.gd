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

func _ready() -> void:
	yield(owner, "ready")
	
	var __ = owner.connect("sleeping_state_changed", self, "_on_owner_sleeping_state_changed")

#### VIRTUALS ####



#### LOGIC ####

# Awake this instance, generaly called by a surrounding body when destoyed
func awake() -> void:
	if disabled:
		return
	
	if not owner is PhysicsBody2D && owner.get_mode() != RigidBody2D.MODE_STATIC:
		return

	owner.set_mode(RigidBody2D.MODE_RIGID)
	owner.set_sleeping(false)
	owner.set_physics_process(true)
	
	emit_signal("awake")


func asleep() -> void:
	if disabled:
		return

	if not owner is PhysicsBody2D && owner.get_mode() != RigidBody2D.MODE_RIGID:
		return
	
	if !owner.can_sleep:
		return
	
	owner.set_mode(RigidBody2D.MODE_STATIC)
	owner.set_sleeping(true)
	owner.set_physics_process(false)
	
	emit_signal("asleep")


#### INPUTS ####



#### SIGNAL RESPONSES ####


# Set the mode back to static mode when the body is sleeping
func _on_owner_sleeping_state_changed():
	if owner.get_mode() == RigidBody2D.MODE_RIGID && owner.is_sleeping():
		owner.call_deferred("set_mode", RigidBody2D.MODE_STATIC)
