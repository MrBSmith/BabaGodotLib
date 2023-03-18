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
export(ALIGN) var title_align : int = ALIGN.LEFT setget set_title_align, get_title_align
export(ALIGN) var body_align : int = ALIGN.RIGHT setget set_body_align, get_body_align

export var title_font : DynamicFont = null setget set_title_font
export var body_font : DynamicFont = null setget set_body_font

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

func set_title_align(value: int) -> void:
	if !value in range(ALIGN.size()):
		return
	
	title_align = value
	$Title.set_align(title_align)
func get_title_align() -> int: return title_align

func set_body_align(value: int) -> void:
	if !value in range(ALIGN.size()):
		return
	
	body_align = value
	$Body.set_align(body_align)
func get_body_align() -> int: return body_align

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
