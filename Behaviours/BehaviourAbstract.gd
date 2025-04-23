extends Node2D
class_name Behaviour

# This is an abstract class for a Behaviour
# Behaviours should be instantiated as a child of the node that should behave in a certain way
# It defines how its parent node behaves

# You can know if a certain node has a certain behaviour by calling node.is_in_group() 
# and passing it the wanted behaviour_type
# You can also fetch the behaviour of a node using Utils.find_behaviour() method

# Behaviours can be disabled by changing the disabled variable's value 
# But you will have to write yourself how the Behaviour will behave with disabled to true


onready var holder = get_node_or_null(holder_path)

export var holder_path := NodePath()

export var behaviour_type: String = "" setget , get_behaviour_type
export var disabled : bool = false setget set_disabled, is_disabled

signal disabled_changed(disabled)

#### ACCESSORS ####

func is_class(value: String): return value == "Behaviour" or .is_class(value)
func get_class() -> String: return "Behaviour"

func get_behaviour_type() -> String: return behaviour_type

func set_disabled(value: bool) -> void: 
	if value != disabled:
		disabled = value
		emit_signal("disabled_changed", disabled)
func is_disabled() -> bool: return disabled

#### BUILT-IN ####

func _ready() -> void:
	if holder == null:
		holder = owner
	
	if !behaviour_type.empty():
		holder.add_to_group(behaviour_type)
		holder.set_meta(behaviour_type, self)


#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####
