extends HSlider
class_name Baba_HSlider

@onready var normal_grabber_texture : Texture2D = get_theme().get_icon("grabber", "HSlider")

@export var hover_grabber_texture : Texture2D = null
@export var pressed_grabber_texuture : Texture2D = null

#### ACCESSORS ####

func is_class(value: String): return value == "Baba_HSlider" or super.is_class(value)
func get_class() -> String: return "Baba_HSlider"


#### BUILT-IN ####


#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####

func _gui_input(event: InputEvent) -> void:
	if !event is InputEventMouseButton:
		return
	
	if !event.is_pressed() && event.button_index == MOUSE_BUTTON_LEFT:
		release_focus()


#### SIGNAL RESPONSES ####

