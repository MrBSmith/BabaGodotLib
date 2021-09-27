extends TextEdit
class_name TextField

onready var placeholder_text = get_text()

export var placeholder_text_color = Color("80e0e0e0")

#### ACCESSORS ####

func is_class(value: String): return value == "TextField" or .is_class(value)
func get_class() -> String: return "TextField"

func get_text() -> String:
	if text == placeholder_text:
		return ""
	else:
		return text

#### BUILT-IN ####

func _ready() -> void:
	var __ = connect("focus_entered", self, "_on_focus_entered")
	__ = connect("focus_exited", self, "_on_focus_exited")
	
	_set_text_as_placeholder()

#### VIRTUALS ####



#### LOGIC ####

func _set_text_as_placeholder() -> void:
	set_text(placeholder_text)
	add_color_override("font_color", placeholder_text_color)


#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_focus_entered() -> void:
	if text == placeholder_text:
		set_text("")
		add_color_override("font_color", get_parent().get_color("font_color", "TextEdit"))


func _on_focus_exited() -> void:
	if text == "":
		_set_text_as_placeholder()
