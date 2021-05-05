extends LineContainer
class_name TextLineContainer

onready var text_label = get_node_or_null("TextLabel")
onready var amount_label = $AmountLabel
onready var texture_rect = $TextureRect

var text : String = "EMPTY" setget set_text, get_text
var amount : int = INF setget set_amount, get_amount
var icon_texture : Texture = null setget set_icon_texture, get_icon_texture

#### ACCESSORS ####

func is_class(value: String): return value == "TextLineContainer" or .is_class(value)
func get_class() -> String: return "TextLineContainer"

func set_text(value: String):
	if !is_ready:
		yield(self, "ready")
	
	text_label.set_text(value)

func get_text() -> String: return text

func set_amount(value: int):
	if !is_ready:
		yield(self, "ready")
	
	amount = value
	
	if amount == int(INF):
		amount_label.queue_free()
		amount_label = null
		_update_alignment()
		return
	
	if value != int(INF):
		amount_label.set_text(String(amount))
	else: 
		amount_label.set_text("")

func get_amount() -> int: return amount

func set_icon_texture(value: Texture):
	if !is_ready:
		yield(self, "ready")
	
	if value == null:
		texture_rect.queue_free()
		texture_rect = null
		_update_alignment()
		return 
	
	icon_texture = value
	texture_rect.set_texture(icon_texture)

func get_icon_texture() -> Texture: return icon_texture

#### BUILT-IN ####

func _ready() -> void:
	yield(self, "ready")
	
	if text_label != null:
		var __ = text_label.connect("resized", self, "_on_text_label_resized")

#### VIRTUALS ####



#### LOGIC ####

func _update_alignment():
	pass


#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_text_label_resized():
	if text_label.get_size().x > get_size().x && text != "":
		text_label.set_autowrap(true)
		text_label.set_size(Vector2(get_size().x, 0))
		text_label.set_custom_minimum_size(Vector2(get_size().x, 0))
