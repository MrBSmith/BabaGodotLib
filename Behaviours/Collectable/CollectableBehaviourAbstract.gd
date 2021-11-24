extends Behaviour
class_name CollectableBehaviour

#### Abstract class CollectableBehaviour ####

# This class can be extended and attached to any node to give 
# it the behaviour of a collectable

onready var collect_sound = get_node_or_null("CollectSound")
onready var travelling_sound = get_node_or_null("CollectSound")
onready var animation_player = get_node_or_null("AnimationPlayer")
onready var collect_area = get_node_or_null("CollectArea")

export var collectable_name : String = "" setget set_collectable_name, get_collectable_name

export var average_amount : int = 1
export(float, 0.0, 1.0) var amount_variance : float = 0.0

var target : Node = null setget set_target, get_target

#warning-ignore:unused_signal
signal interactable_changed
#warning-ignore:unused_signal
signal collect_animation_finished

#### ACCESSORS ####

func is_class(value: String): return value == "CollectableBehaviour" or .is_class(value)
func get_class() -> String: return "CollectableBehaviour"

func set_target(value: Node): 
	target = value
func get_target() -> Node: return target

func set_collectable_name(value: String): collectable_name = value
func get_collectable_name() -> String:
	var col_name = collectable_name if collectable_name != "" or owner == null else owner.get_class()
	return col_name


#### BUILT-IN ####

func _ready():
	var __ = connect("collect_animation_finished", self, "_on_collect_animation_finished")
	__ = collect_area.connect("body_entered", self, "_on_collect_area_body_entered")
	__ = connect("interactable_changed", self, "_on_interactable_changed")
	
	if animation_player:
		animation_player.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")

#### VIRTUALS ####



#### LOGIC ####

func collect() -> void:
	pass


func trigger_collect_animation() -> void:
	pass


func compute_amount_collected() -> int:
	return -1


func collect_success() -> void:
	pass

#### INPUTS ####



#### SIGNAL RESPONSES ####


func _on_collect_area_body_entered(_body: PhysicsBody2D) -> void:
	pass


func _on_collect_animation_finished() -> void:
	pass


func _on_interactable_changed() -> void:
	pass


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	pass
