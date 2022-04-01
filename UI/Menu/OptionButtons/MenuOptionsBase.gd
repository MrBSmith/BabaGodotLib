tool
extends Control
class_name MenuOptionsBase

onready var _button = $HBoxContainer/MarginContainer/Button setget , get_button
onready var h_box_container = $HBoxContainer

onready var hover_textures = [$HBoxContainer/HoverTexture, $HBoxContainer/HoverTexture2]

signal disabled_changed(disabled)
signal focus_changed(entity, focus)
signal option_chose(menu_option)
signal hidden_changed
signal text_changed(text)

var is_ready : bool = false
var focused : bool = false setget set_focused, is_focused

export var hidden : bool = false setget set_hidden, is_hidden
export var all_caps : bool = false setget set_all_caps
export var text : String = "Button" setget set_text, get_text 
export var disabled : bool = false setget set_disabled, is_disabled

#### ACCESSSORS ####

func set_focused(value: bool):
	if _button == null: 
		return
	if value != focused && !_button.is_disabled():
		focused = value
		if focused: 
			_button.grab_focus()
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

func set_hidden(value: bool):
	if value != hidden:
		hidden = value
		emit_signal("hidden_changed")
func is_hidden() -> bool: return hidden

func set_disabled(value: bool):
	if !is_ready:
		yield(self, "ready")
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

#### BUILT-IN ####

func _ready() -> void:
	add_to_group("MenuOption")
	
	var _err = _button.connect("focus_entered", self, "_on_focus_entered")
	_err = _button.connect("focus_exited", self, "_on_focus_exited")
	_err = _button.connect("pressed", self, "_on_pressed")
	_err = _button.connect("mouse_entered", self, "_on_mouse_entered")
	_err = _button.connect("mouse_exited", self, "_on_mouse_exited")
	_err = _button.connect("button_down", self, "_on_button_down")
	_err = _button.connect("button_up", self, "_on_button_up")
	
	_err = connect("disabled_changed", self, "_on_disabled_changed")
	_err = connect("focus_changed", self, "_on_focus_changed")
	_err = connect("gui_input", self, "_on_gui_input")
	
	set_text(text)
	
	if !Engine.editor_hint:
		_err = connect("hidden_changed", self, "_on_hidden_changed")
		_on_hidden_changed()
		emit_signal("focus_changed", self, is_focused())
	
	is_ready = true


#### LOGIC ####

func set_hover_icons_modulate(color: Color) -> void:
	for hover_texture in h_box_container.get_children():
		if hover_texture is TextureRect:
			hover_texture.set_modulate(color)

#### SIGNAL RESPONSES ####

func _on_gui_input(event : InputEvent): 
	if event.is_action_pressed("ui_accept") && is_focused():
		_button.set_pressed(true)


func _on_pressed():
	emit_signal("option_chose", self)


func _on_mouse_entered():
	if !is_disabled() && !is_hidden():
		set_focused(true)


func _on_mouse_exited():
	if !is_disabled():
		set_focused(false)


func _on_focus_entered():
	if !hidden:
		set_focused(true)


func _on_focus_exited():
	set_focused(false)


func _on_focus_changed(entity: Control, focus: bool) -> void:
	if !Engine.editor_hint:
		var button_focus_color = entity.get_color("font_color_hover", "Button")
		var dest_color = button_focus_color if focus else Color.transparent
		
		set_hover_icons_modulate(dest_color)


func _on_hidden_changed() -> void:
	
	if hidden:
		set_modulate(Color.transparent)
	else:
		set_modulate(Color.white)
		
		if _button.is_hovered() && !is_disabled():
			set_focused(true)


func _on_button_down() -> void:
	var pressed_color = _button.get_color("font_color_pressed", "Button")
	set_hover_icons_modulate(pressed_color)


func _on_button_up() -> void:
	var focus_color = _button.get_color("font_color_hover", "Button")
	set_hover_icons_modulate(focus_color)


func _on_disabled_changed(_value: bool) -> void:
	for texture in hover_textures:
		var alpha = int(!disabled)
		texture.self_modulate.a = alpha
