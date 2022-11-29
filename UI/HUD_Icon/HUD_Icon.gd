extends TextureRect
class_name HUD_Icon

@export var empty : bool = false :
	set(value):
		if value != empty:
			empty = value
			empty_changed.emit()

signal empty_changed

#### ACCESSORS ####

func is_class(value: String): return value == "HUD_Icon" or super.is_class(value)
func get_class() -> String: return "HUD_Icon"

#### BUILT-IN ####

func _ready() -> void:
	var __ = connect("empty_changed",Callable(self,"_on_empty_changed"))
	
	_on_empty_changed()


#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_empty_changed() -> void:
	var texture_size = texture.get_atlas().get_size()
	var texture_x = 0 if !empty else texture_size.x / 2 
	
	var rect = Rect2(texture_x, 0, texture_size.x / 2, texture_size.y)
	texture.set_region_enabled(rect)
