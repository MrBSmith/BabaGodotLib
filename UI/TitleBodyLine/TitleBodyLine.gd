tool
extends HBoxContainer
class_name TitleDataLabel

enum ALIGN {
	LEFT,
	CENTER,
	RIGHT,
	FILL
}

export var title_text : String = "Title: " setget set_title_text, get_title_text
export var body_text: String = "Body" setget set_body_text, get_body_text
export(ALIGN) var align : int = ALIGN.LEFT setget set_align, get_align


#### ACCESSORS ####

func is_class(value: String): return value == "TitleDataLabel" or .is_class(value)
func get_class() -> String: return "TitleDataLabel"

func set_title_text(value: String): 
	title_text = value
	$Title.set_text(title_text)
func get_title_text() -> String: return title_text

func set_body_text(value: String):
	body_text = value
	$Body.set_text(body_text)
func get_body_text() -> String: return body_text

func set_align(value: int) -> void:
	if !value in range(ALIGN.size()):
		return
	
	align = value
	
	for child in get_children():
		if child.has_method("set_align"):
			child.set_align(align)
func get_align() -> int: return align

func set_title_font_color(color: Color) -> void:
	$Title.add_color_override("font_color", color)
func set_body_font_color(color: Color) -> void:
	$Body.add_color_override("font_color", color)

func set_font(font: DynamicFont) -> void:
	set_title_font(font)
	set_body_font(font)
func set_title_font(font: DynamicFont) -> void:
	$Title.add_font_override("font", font)
func set_body_font(font: DynamicFont) -> void:
	$Body.add_font_override("font", font)

#### BUILT-IN ####



#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####
