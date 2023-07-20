tool
extends State
class_name ActorActionState

export var animated_sprite_path : NodePath
export var hitboxes_container_path : NodePath
export var impact_anim_node_path : NodePath
export var wrong_impact_hitbox_path : NodePath

export var interact_frame : int = -1

onready var wrong_impact_hitbox = get_node_or_null(wrong_impact_hitbox_path)
onready var hitboxes_container = get_node_or_null(hitboxes_container_path)
onready var animated_sprite = get_node(animated_sprite_path)
onready var impact_sound = get_node_or_null("ImpactSound")
onready var impact_anim = get_node_or_null(impact_anim_node_path)


#### ACCESSORS ####

func is_class(value: String): return value == "RT_ActorActionState" or .is_class(value)
func get_class() -> String: return "RT_ActorActionState"


#### BUILT-IN ####

func _ready() -> void:
	yield(owner, "ready")
	
	var __ = animated_sprite.connect("frame_changed", self, "_on_animation_frame_changed")
	
	if impact_anim:
		__ = impact_anim.connect("animation_finished", self, "_on_impact_animation_finished")



#### VIRTUALS ####


#### LOGIC ####

func interact():
	if !is_instance_valid(hitboxes_container):
		return
	
	var damaged_bodies = []
	var wrong_impact = false
	
	# Damage every bodies found in hitboxes
	for hitbox in hitboxes_container.get_children():
		if not hitbox is Area2D or !hitbox.monitoring:
			continue
		
		var raycast = hitbox.get_node_or_null("RayCast2D")
		
		if raycast:
			raycast.set_enabled(true)
			yield(get_tree(), "physics_frame")
		
		for body in hitbox.get_overlapping_bodies():
			if body in damaged_bodies or body == owner:
				continue
			
			if !has_obstacle_in_the_way(body, raycast):
				var is_interactable = is_obj_interactable(body)
				
				if is_interactable:
					damage(body)
					damaged_bodies.append(body)
				
				if hitbox == wrong_impact_hitbox:
					if !is_interactable:
						wrong_impact = true
				else:
					if !is_interactable and not body is TileMap:
						wrong_impact = true
		
		if raycast:
			raycast.set_enabled(false)
	
	var has_damaged = !damaged_bodies.empty()
	
	# Play the feedbacks animations
	if has_damaged:
		if impact_anim:
			impact_anim.set_frame(0)
			impact_anim.set_visible(true)
			impact_anim.play()
	
	elif wrong_impact:
		if animated_sprite.get_sprite_frames().has_animation("WrongAction"):
			animated_sprite.play("WrongAction")
	
	# Play the sound effect
	if (has_damaged or wrong_impact) && impact_sound:
		EVENTS.emit_signal("play_sound_effect", impact_sound)



func has_obstacle_in_the_way(body: PhysicsBody2D, raycast: RayCast2D) -> bool:
	if !is_instance_valid(raycast) or !is_instance_valid(body):
		return false
	
	raycast.clear_exceptions()
	raycast.add_exception(body)
	raycast.set_cast_to(raycast.to_local(body.global_position))
	raycast.force_raycast_update()
	
	return raycast.is_colliding()


# Damage a block if it is in the hitbox area, and if his type correspond to the current robot breakable type
func damage(body: PhysicsBody2D) -> void:
	if !is_instance_valid(body):
		return
	
	var average_pos = (body.global_position + owner.global_position) / 2
	EVENTS.emit_signal("play_VFX", "great_hit", average_pos, {})
	
	if body.is_in_group("Destructible") && is_obj_interactable(body):
		var destructible_behaviour = Utils.find_behaviour(body, "Destructible")
		if destructible_behaviour:
			NETWORK.rpc_or_direct_call(destructible_behaviour, "damage")


func is_obj_interactable(obj: Object) -> bool:
	var interactables = owner.get("interactables")
	
	if interactables == null:
		return true
	
	for string in interactables:
		if obj.is_class(string):
			return true
	return false




#### INPUTS ####



#### SIGNAL RESPONSES ####
 
func _on_animation_frame_changed() -> void:
	if !is_current_state() or animated_sprite.get_animation() != name:
		return
	
	if animated_sprite.get_frame() == interact_frame:
		interact()



func _on_impact_animation_finished() -> void:
	if impact_anim:
		impact_anim.stop()
		impact_anim.set_visible(false)
