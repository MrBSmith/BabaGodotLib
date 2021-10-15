extends ActorActionState
class_name RT_ActorActionState

export var interact_frame : int = 2

var action_hitbox_node : Area2D
var hit_box_shape : Node

var has_damaged : bool = false

#### ACCESSORS ####

func is_class(value: String): return value == "RT_ActorActionState" or .is_class(value)
func get_class() -> String: return "RT_ActorActionState"


#### BUILT-IN ####

func _ready() -> void:
	yield(owner, "ready")
	
	var __ = animated_sprite.connect("frame_changed", self, "_on_animation_frame_changed")
	action_hitbox_node = owner.get_node_or_null("ActionHitBox")
	hit_box_shape = action_hitbox_node.get_node_or_null("CollisionShape2D")


#### VIRTUALS ####


#### LOGIC ####

func interact():
	# Get every area in the hitbox area
	var interact_areas = action_hitbox_node.get_overlapping_areas()
	
	damage()
	
	# Check if one on the areas in the hitbox area is an interative one, and interact with it if it is
	# Also verify if no block were broke in this use of the action state
	if !has_damaged:
		for area in interact_areas:
			if is_obj_interactable(area):
				area.interact(hit_box_shape.global_position)
	
	
	if is_wrong_interaction() && animated_sprite.get_sprite_frames().has_animation("WrongAction"):
		animated_sprite.play("WrongAction")


# Damage a block if it is in the hitbox area, and if his type correspond to the current robot breakable type
func damage():
	var bodies_in_hitbox = action_hitbox_node.get_overlapping_bodies()
	for body in bodies_in_hitbox:
		if body == owner or body.owner == owner or body is TileMap:
			continue
		
		var average_pos = (body.global_position + action_hitbox_node.global_position) / 2
		EVENTS.emit_signal("play_SFX", "great_hit", average_pos)
		
		if is_obj_interactable(body):
			body.damage(owner)
			has_damaged = true


func is_wrong_interaction() -> bool:
	var bodies = action_hitbox_node.get_overlapping_bodies()
	var has_external_elem = false
	
	for body in bodies:
		if owner.is_a_parent_of(body) or body == owner:
			continue
		
		has_external_elem = true
		if is_obj_interactable(body):
			return false
	
	return has_external_elem



#### INPUTS ####



#### SIGNAL RESPONSES ####
 
func _on_animation_frame_changed() -> void:
	if !is_current_state() or animated_sprite.get_animation() != name:
		return
	
	if animated_sprite.get_frame() == interact_frame:
		interact()

