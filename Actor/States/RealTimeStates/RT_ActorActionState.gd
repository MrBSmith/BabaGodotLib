extends ActorActionState
class_name RT_ActorActionState

var action_hitbox_node : Area2D
var hit_box_shape : Node

#### ACCESSORS ####

func is_class(value: String): return value == "RT_ActorActionState" or .is_class(value)
func get_class() -> String: return "RT_ActorActionState"


#### BUILT-IN ####

func _ready() -> void:
	yield(owner, "ready")

	action_hitbox_node = owner.get_node_or_null("ActionHitBox")
	hit_box_shape = action_hitbox_node.get_node_or_null("CollisionShape2D")


#### VIRTUALS ####



#### LOGIC ####

func interact():
	# Get every area in the hitbox area
	var interact_areas = action_hitbox_node.get_overlapping_areas()
	
	# Check if one on the areas in the hitbox area is an interative one, and interact with it if it is
	# Also verify if no block were broke in this use of the action state
	for area in interact_areas:
		if is_obj_interactable(area):
			area.interact(hit_box_shape.global_position)



#### INPUTS ####



#### SIGNAL RESPONSES ####
