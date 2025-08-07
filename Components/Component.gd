extends Node
class_name Component

@export var holder_path := NodePath()
@onready var holder = owner if holder_path.is_empty() else get_node_or_null(holder_path)

func _ready() -> void:
	var component_name = get_component_name()
	holder.add_to_group(component_name)
	holder.set_meta(component_name, self)


func get_component_name() -> String:
	return get_script().get_global_name()
