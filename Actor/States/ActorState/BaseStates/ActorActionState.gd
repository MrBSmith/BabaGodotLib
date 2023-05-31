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
	
	# Damage every bodies found in hitboxes
	for hitbox in hitboxes_container.get_children():
		if not hitbox is Area2D or !hitbox.monitoring:
			continue
		
		for body in hitbox.get_overlapping_bodies():
			if body in damaged_bodies or body == owner:
				continue
			
			if is_obj_interactable(body):
				damage(body)
				damaged_bodies.append(body)
	
	var has_damaged = !damaged_bodies.empty()
	var wrong_impact = has_wrong_impact()
	
	# Play the animation
	if !has_damaged and wrong_impact:
		if animated_sprite.get_sprite_frames().has_animation("WrongAction"):
			animated_sprite.play("WrongAction")
	else:
		if impact_anim:
			impact_anim.set_frame(0)
			impact_anim.set_visible(true)
			impact_anim.play()
	
	# Play the sound effect
	if (has_damaged or wrong_impact) && impact_sound:
		EVENTS.emit_signal("play_sound_effect", impact_sound)


# Damage a block if it is in the hitbox area, and if his type correspond to the current robot breakable type
func damage(body: PhysicsBody2D) -> void:
	if !is_instance_valid(body):
		return
	
	var average_pos = (body.global_position + owner.global_position) / 2
	EVENTS.emit_signal("play_VFX", "great_hit", average_pos, {})
	
	if body.is_in_group("Destructible") && is_obj_interactable(body):
		var destructible_behaviour = Utils.find_behaviour(body, "Destructible")
		if destructible_behaviour:
			destructible_behaviour.damage()


func is_obj_interactable(obj: Object) -> bool:
	var interactables = owner.get("interactables")
	
	if interactables == null:
		return true
	
	for string in interactables:
		if obj.is_class(string):
			return true
	return false


func has_wrong_impact() -> bool:
	for body in wrong_impact_hitbox.get_overlapping_bodies():
		if body == owner:
			continue
		
		if !is_obj_interactable(body):
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
