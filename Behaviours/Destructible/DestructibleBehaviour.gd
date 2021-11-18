extends Behaviour
class_name DestructibleBehaviour

onready var animation_player = get_node_or_null("AnimationPlayer")
onready var damage_computer = get_node_or_null("DamageComputer")
onready var destroy_sound = get_node_or_null("DestroySound")
onready var approch_area = get_node_or_null("ApprochArea")

export var max_hp : int = 1
export var hp : int = max_hp setget set_hp, get_hp

signal hp_changed(hp_value)
signal destroy_animation_started()
signal damaged()
signal destroyed()
signal body_approched(body)

#### ACCESSORS ####

func is_class(value: String): return value == "DestructibleBehaviour" or .is_class(value)
func get_class() -> String: return "DestructibleBehaviour"

func set_hp(value: int) -> void:
	if value != hp:
		hp = value
		emit_signal("hp_changed", hp)
func get_hp() -> int: return hp 


#### BUILT-IN ####

func _ready() -> void:
	var __ = connect("hp_changed", self, "_on_hp_changed")
	if approch_area:
		__ = approch_area.connect("body_entered", self, "_on_body_entered")
	
	owner.add_to_group("Destructible")



#### VIRTUALS ####



#### LOGIC ####

func damage() -> void:
	if damage_computer:
		set_hp(Math.clampi(hp - damage_computer.compute_damage(), 0, max_hp))
	else:
		set_hp(Math.clampi(hp - 1, 0, max_hp))


func destroy() -> void:
	if destroy_sound:
		EVENTS.emit_signal("play_sound_effect", destroy_sound)
	
	if animation_player && animation_player.has_animation("Destroy"):
		emit_signal("destroy_animation_started")
		animation_player.play("Destroy")
		yield(animation_player, "animation_finished")
	
	emit_signal("destroyed")
	owner.queue_free()


#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_hp_changed(hp_value: int) -> void:
	emit_signal("damaged")
	if animation_player && animation_player.has_animation("Damage"):
		animation_player.play("Damage")
	
	if hp_value == 0:
		destroy()


func _on_body_entered(body: Node2D) -> void:
	emit_signal("body_approched", body)
