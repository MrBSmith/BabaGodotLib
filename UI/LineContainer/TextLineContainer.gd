@tool
extends LineContainer
class_name TextLineContainer

@onready var text_label = get_node_or_null("TextLabel")
@onready var counter_label = get_node_or_null("CounterLabel")
@onready var texture_rect = get_node_or_null("TextureRect")

@export var text : String : get = get_text, set = set_text
@export var amount : int = INF : get = get_amount, set = set_amount
@export var icon_texture : Texture2D = null : get = get_icon_texture, set = set_icon_texture

signal text_changed(text)
signal amount_changed(amount)
signal icon_texture_changed(texture)

#### ACCESSORS ####

func is_class(value: String): return value == "TextLineContainer" or super.is_class(value)
func get_class() -> String: return "TextLineContainer"

func set_text(value: String):
	if value != text:
		text = value
		emit_signal("text_changed", text)
func get_text() -> String: return text

func set_amount(value: int):
	if amount != value:
		amount = value
		emit_signal("amount_changed", amount)
func get_amount() -> int: return amount

func set_icon_texture(value: Texture2D):
	if value != icon_texture:
		icon_texture = value
		emit_signal("icon_texture_changed", icon_texture)
func get_icon_texture() -> Texture2D: return icon_texture


#### BUILT-IN ####

func _init():
	var __ = connect("amount_changed",Callable(self,"_on_amount_changed"))
	__ = connect("text_changed",Callable(self,"_on_text_changed"))
	__ = connect("icon_texture_changed",Callable(self,"_on_icon_texture_changed"))
	

func _ready() -> void:
	if text_label != null:
		var __ = text_label.connect("resized",Callable(self,"_on_text_label_resized"))
	
	_on_text_changed(text)
	_on_amount_changed(amount)
	_on_icon_texture_changed(icon_texture)


#### VIRTUALS ####



#### LOGIC ####

func _update_alignment():
	pass


#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_text_label_resized():
	if text_label.get_size().x > get_size().x && text != "":
		text_label.set_autowrap_mode(true)
		text_label.set_size(Vector2(get_size().x, 0))
		text_label.set_custom_minimum_size(Vector2(get_size().x, 0))

func _on_amount_changed(_value: int) -> void:
	if counter_label:
		if Engine.editor_hint:
			counter_label.set_amount(amount)
		else:
			counter_label.tween_amount(amount)

func _on_text_changed(_value: String) -> void:
	if text_label:
		text_label.set_text(text)

func _on_icon_texture_changed(_value: Texture2D) -> void:
	if texture_rect:
		texture_rect.set_texture(icon_texture)
