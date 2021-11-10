extends Node2D
class_name CollectableBehaviour

#### Abstract class CollectableBehaviour ####

# This class can be extended and attached to ant node to give 
# it the behaviour of a collectable

onready var state_machine = $StatesMachine

onready var animation_player = get_node_or_null("AnimationPlayer")
onready var collect_area = get_node_or_null("CollectArea")

export var collectable_name : String = "" setget set_collectable_name, get_collectable_name
export var interactable : bool = true setget set_interactable, is_interactable

export var average_amount : int = 1
export(float, 0.0, 1.0) var amount_variance : float = 0.0

export var default_state : String = ""

var target : Node = null setget set_target, get_target

#warning-ignore:unused_signal
signal interactable_changed

#### ACCESSORS ####

func is_class(value: String): return value == "CollectableBehaviour" or .is_class(value)
func get_class() -> String: return "CollectableBehaviour"

func set_state(state): state_machine.set_state(state)
func get_state() -> Object: return state_machine.get_state()
func get_state_name(): return state_machine.get_state_name()

func set_interactable(value: bool):
	if value != interactable:
		interactable = value
		emit_signal("interactable_changed")
func is_interactable() -> bool: return interactable

func set_target(value: Node): target = value
func get_target() -> Node: return target

func set_collectable_name(value: String): collectable_name = value
func get_collectable_name() -> String: return collectable_name

signal collect_animation_finished

#### BUILT-IN ####

func _ready():
	var __ = connect("collect_animation_finished", self, "_on_collect_animation_finished")
	__ = collect_area.connect("body_entered", self, "_on_collect_area_body_entered")
	__ = connect("interactable_changed", self, "_on_interactable_changed")


#### VIRTUALS ####



#### LOGIC ####

func collect() -> void:
	pass


func trigger_collect_animation() -> void:
	pass


func compute_amount_collected() -> int:
	return -1


#### INPUTS ####



#### SIGNAL RESPONSES ####


func _on_collect_area_body_entered(_body: PhysicsBody2D) -> void:
	pass


func _on_collect_animation_finished() -> void:
	pass


func _on_interactable_changed() -> void:
	pass
