extends TextureRect
class_name HUD_Icon

export var empty : bool = false setget set_empty, is_empty

signal empty_changed

#### ACCESSORS ####

func is_class(value: String): return value == "HUD_Icon" or .is_class(value)
func get_class() -> String: return "HUD_Icon"

func set_empty(value: bool) -> void:
	if value != empty:
		empty = value
		emit_signal("empty_changed")
func is_empty() -> bool: return empty

#### BUILT-IN ####

func _ready() -> void:
	var __ = connect("empty_changed", self, "_on_empty_changed")
	
	_on_empty_changed()


#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_empty_changed() -> void:
	var texture_size = texture.get_atlas().get_size()
	var texture_x = 0 if !empty else texture_size.x / 2 
	
	var rect = Rect2(texture_x, 0, texture_size.x / 2, texture_size.y)
	texture.set_region(rect)
