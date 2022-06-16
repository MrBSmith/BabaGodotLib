tool
extends TextLineContainer
class_name OptionLineContainer

enum ALIGN {
	LEFT,
	CENTER,
	RIGHT
}

onready var option = $MenuOptionBase
onready var option_button = $MenuOptionBase/HBoxContainer/Button

signal option_chose(option_ref)
signal focus_changed(entity, focus)

export(ALIGN) var align : int = ALIGN.CENTER

#### ACCESSORS ####

func is_class(value: String): return value == "OptionLineContainer" or .is_class(value)
func get_class() -> String: return "OptionLineContainer"

# Override
func set_hidden(value: bool):
	.set_hidden(value)
	
	if value == false && option.is_focused():
		emit_signal("focus_changed", option_button, option_button.is_focused())


func set_text(value: String):
	if !is_ready:
		yield(self, "ready")
	
	text = value
	option_button.set_text(text)
	option_button.set_name(text)

func get_text() -> String: return text

func set_disabled(value: bool):
	if !is_ready:
		yield(self, "ready")
	
	option_button.set_disabled(value)

func set_all_caps(value: bool):
	option_button.set_all_caps(value)
	_update_alignment()

#### BUILT-IN ####

func _ready() -> void:
	var __ = option.connect("option_chose", self, "_on_button_option_chose")
	__ = option.connect("focus_changed", self, "_on_focus_changed")
	
	option_button.set_text_align(align)
	option.size_flags_horizontal = 2

#### VIRTUALS ####



#### LOGIC ####

func _update_alignment():
	._update_alignment()
	
	if amount == int(INF) && icon_texture == null:
		set_alignment(BoxContainer.ALIGN_END)
		option_button.set_text_align(Button.ALIGN_RIGHT)
	else:
		set_alignment(BoxContainer.ALIGN_BEGIN)
		option_button.set_text_align(Button.ALIGN_LEFT)

	if get_alignment() == BoxContainer.ALIGN_BEGIN:
		default_margin_left = 0.0
		set_margin(MARGIN_LEFT, default_margin_left)


#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_button_option_chose(_option: MenuOptionsBase):
	emit_signal("option_chose", _option)


func _on_focus_changed(button: Button, focused: bool):
	if !hidden:
		emit_signal("focus_changed", button, focused)
	
	if amount_label == null:
		return
	
	if focused:
		amount_label.set_modulate(button.get_color("font_color_hover"))
	else:
		amount_label.set_modulate(button.get_color("font_color"))
