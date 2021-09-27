extends LineEdit
class_name LineField

onready var default_placeholder_text = get_placeholder()

#### ACCESSORS ####

func is_class(value: String): return value == "LineField" or .is_class(value)
func get_class() -> String: return "LineField"


#### BUILT-IN ####

func _ready() -> void:
	var __ = connect("focus_entered", self, "_on_focus_entered")
	__ = connect("focus_exited", self, "_on_focus_exited")

#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_focus_entered() -> void:
	set_placeholder("")


func _on_focus_exited() -> void:
	set_placeholder(default_placeholder_text)
