tool
extends TileMap
class_name IsoMapLayer

# A base class to represent a IsoMapLayer


func _ready() -> void:
	var _err = EVENTS.connect("hide_iso_objects", self, "_on_hide_iso_objects_event")
	
	if !Engine.editor_hint:
		set_visible(false)



#### SIGNAL RESPONSES ####

func _on_hide_iso_objects_event(hide: bool):
	set_visible(!hide)
