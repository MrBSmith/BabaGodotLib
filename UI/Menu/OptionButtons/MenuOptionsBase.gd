@tool
extends Control
class_name MenuOptionsBase

enum TEXTURE_FLAGS {
	LEFT = 1,
	RIGHT = 2
}

@export var hover_texture : Texture2D : set = set_hover_texture

@export_flags(TEXTURE_FLAGS) var hover_texture_flags = TEXTURE_FLAGS.LEFT | TEXTURE_FLAGS.RIGHT

@onready var _button = $HBoxContainer/Button : get = get_button
@onready var h_box_container = $HBoxContainer

@onready var hover_sprites = [$HBoxContainer/HoverTexture, $HBoxContainer/HoverTexture2]

signal disabled_changed(disabled)
signal focus_changed(entity, focus)
signal option_chose(menu_option)
signal hidden_changed
signal text_changed(text)

var is_ready : bool = false
var focused : bool = false : get = is_focused, set = set_focused

@export var all_caps : bool = false : set = set_all_caps
@export var text : String = "Button" : get = get_text, set = set_text 
@export var disabled : bool = false : get = is_disabled, set = set_disabled

#### ACCESSSORS ####

func set_focused(value: bool):
	if _button == null: 
		return
	if value != focused && !_button.is_disabled():
		focused = value
		if focused:
			_button.grab_focus()
		else:
			_button.release_focus()
		if is_ready:
			emit_signal("focus_changed", self, focused)
func is_focused() -> bool: return focused

func set_all_caps(value: bool):
	if _button == null: return
	all_caps = value
	if all_caps:
		_button.set_text(_button.get_text().to_upper())
	else:
		_button.set_text(_button.get_text().capitalize())

func set_text(value: String):
	var text_changed = text != value
	text = value
	if _button == null: return
	if all_caps:
		_button.set_text(value.to_upper())
	else:
		_button.set_text(value)
	if text_changed:
		emit_signal("text_changed", text)
func get_text() -> String: 
	if _button == null: 
		return ""
	return _button.get_text()

func set_disabled(value: bool):
	if !is_ready:
		await self.ready
	if value != _button.is_disabled():
		disabled = value
		_button.set_disabled(value)
		emit_signal("disabled_changed", value)
func is_disabled() -> bool:
	if _button == null: return false
	return _button.is_disabled()

func is_accessible() -> bool:
	return is_visible() && !is_disabled()

func get_button() -> Button:
	return _button

func set_hover_texture(value: Texture2D) -> void:
	hover_texture = value
	
	if !is_inside_tree():
		await self.ready
	
	for sprite in hover_sprites:
		sprite.set_texture(hover_texture)
func set_hover_texture_flags(value: int) -> void:
	hover_texture_flags = value
	
	$HBoxContainer/HoverTexture.set_visible(hover_texture_flags & TEXTURE_FLAGS.LEFT)
	$HBoxContainer/HoverTexture2.set_visible(hover_texture_flags & TEXTURE_FLAGS.RIGHT)


func is_class(value: String): return value == "MenuOptionsBase" or super.is_class(value)
func get_class() -> String: return "MenuOptionsBase"

#### BUILT-IN ####

func _ready() -> void:
	add_to_group("MenuOption")
	
	_button.focus_entered.connect(_on_focus_entered)
	_button.focus_exited.connect(_on_focus_exited)
	_button.pressed.connect(_on_pressed)
	_button.mouse_entered.connect(_on_mouse_entered)
	_button.mouse_exited.connect(_on_mouse_exited)
	_button.button_down.connect(_on_button_down)
	_button.button_up.connect(_on_button_up)
	
	disabled_changed.connect(_on_disabled_changed)
	focus_changed.connect(_on_focus_changed)
	gui_input.connect(_on_gui_input)
	
	set_text(text)
	
	if !Engine.editor_hint:
		focus_changed.emit(self, is_focused())
	
	is_ready = true


#### LOGIC ####

func set_hover_icons_modulate(color: Color) -> void:
	for child in h_box_container.get_children():
		if child is TextureRect:
			child.set_modulate(color)



#### SIGNAL RESPONSES ####

func _on_gui_input(event : InputEvent): 
	if event.is_action_pressed("ui_accept") && is_focused():
		_button.set_pressed(true)


func _on_pressed():
	emit_signal("option_chose", self)


func _on_mouse_entered():
	if !is_disabled() && visible:
		set_focused(true)


func _on_mouse_exited():
	if !is_disabled():
		set_focused(false)


func _on_focus_entered():
	if visible:
		set_focused(true)


func _on_focus_exited():
	set_focused(false)


func _on_focus_changed(entity: Control, focus: bool) -> void:
	if !Engine.editor_hint:
		var button_focus_color = entity.get_color("font_color_hover", "Button")
		var dest_color = button_focus_color if focus else Color.TRANSPARENT
		
		set_hover_icons_modulate(dest_color)


func _on_button_down() -> void:
	var pressed_color = _button.get_color("font_color_pressed", "Button")
	set_hover_icons_modulate(pressed_color)


func _on_button_up() -> void:
	var focus_color = _button.get_color("font_color_hover", "Button")
	set_hover_icons_modulate(focus_color)


func _on_disabled_changed(_value: bool) -> void:
	for sprite in hover_sprites:
		var alpha = int(!disabled)
		sprite.self_modulate.a = alpha
