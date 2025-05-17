extends Node
class_name Trait

@export var holder_path := NodePath()
@onready var holder = owner if holder_path.is_empty() else get_node_or_null(holder_path)


func _ready() -> void:
	var trait_name = get_trait_name()
	holder.add_to_group(trait_name)
	holder.set_meta(trait_name, self)


func get_trait_name() -> String:
	return get_script().get_global_name()
