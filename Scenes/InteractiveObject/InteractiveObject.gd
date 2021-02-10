extends Node2D
class_name InteractiveObject

export var turn_based = false
export var default_state : String = ""
export var interactable : bool = true setget set_interactable, is_interactable

onready var interact_area = get_node_or_null("InteractArea")

var is_ready : bool = false

#### ACCESSORS ####

func is_class(value: String): return value == "InteractiveObject" or .is_class(value)
func get_class() -> String: return "InteractiveObject"

func set_interactable(value: bool): 
	interactable = value
	
	# Desactivate every area2D
	if interact_area != null:
		interact_area.set_deferred("monitoring", value)

func is_interactable() -> bool: return interactable

#### BUILT-IN ####

func _ready() -> void:
	var __ = Events.connect("interact", self, "_on_interact")
	
	is_ready = true

#### VIRTUALS ####

func interact():
	pass

#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_interact():
	if !is_interactable():
		return
	
	if turn_based:
		interact()
	else:
		var bodies_array = interact_area.get_overlapping_bodies()
		for body in bodies_array:
			if body is Player:
				interact()

