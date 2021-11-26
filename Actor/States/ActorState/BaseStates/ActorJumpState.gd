extends StateBase
class_name ActorJumpState

var SFX_node : Node

#### ACCESSORS ####

func is_class(value: String): return value == "ActorJumpState" or .is_class(value)
func get_class() -> String: return "ActorJumpState"


#### BUILT-IN ####

func _ready():
	yield(owner, "ready")
	SFX_node = owner.get_node_or_null("SFX")



#### VIRTUALS ####

func enter_state():
	.enter_state()
	
	# Genreate the jump dust
	if owner.is_on_floor() && SFX_node != null:
		SFX_node.play_SFX("JumpDust", true, owner.global_position)


func exit_state():
	if SFX_node != null:
		SFX_node.play_SFX("JumpDust", false)
		SFX_node.reset_SFX("JumpDust")

#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_animation_finished():
	pass
