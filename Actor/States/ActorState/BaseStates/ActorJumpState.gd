extends State
class_name ActorJumpState

var VFX_node : Node

#### ACCESSORS ####

func is_class(value: String): return value == "ActorJumpState" or .is_class(value)
func get_class() -> String: return "ActorJumpState"


#### BUILT-IN ####

func _ready():
	yield(owner, "ready")
	VFX_node = owner.get_node_or_null("VFX")


#### VIRTUALS ####

func enter_state():
	.enter_state()
	
	# Genreate the jump dust
	if owner.is_on_floor() && VFX_node != null:
		VFX_node.play_VFX("JumpDust", true)


func exit_state():
	if VFX_node != null:
		VFX_node.play_VFX("JumpDust", false)
		VFX_node.reset_VFX("JumpDust")


func update_state(_delta):
	if owner.is_on_floor() or owner.ignore_gravity:
		return "Idle"
	
	elif owner.velocity.y > 0:
		return "Fall"



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_animation_finished():
	pass
