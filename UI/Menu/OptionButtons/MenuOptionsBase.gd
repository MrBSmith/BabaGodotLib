tool
extends Control
class_name MenuOptionsBase

enum TEXTURE_FLAGS {
	LEFT = 1,
	RIGHT = 2
}

export var hover_texture : Texture setget set_hover_texture

export(int, FLAGS, "Left", "Right") var hover_texture_flags = TEXTURE_FLAGS.LEFT | TEXTURE_FLAGS.RIGHT setget set_hover_texture_flags

onready var _button = $HBoxContainer/Button setget , get_button
onready var h_box_container = $HBoxContainer

onready var hover_sprites = [$HBoxContainer/HoverTexture, $HBoxContainer/HoverTexture2]

signal disabled_changed(disabled)
signal focus_changed(entity, focus)
signal option_chose(menu_option)
signal hidden_changed
signal text_changed(text)
signal hover_texture_flags_changed()
signal all_caps_changed()
signal hover_texture_changed()

var focused : bool = false setget set_focused, is_focused

export var hidden : bool = false setget set_hidden, is_hidden
export var all_caps : bool = false setget set_all_caps
export var text : String = "Button" setget set_text, get_text 
export var disabled : bool = false setget set_disabled, is_disabled

#### ACCESSSORS ####

func set_focused(value: bool):
	if value != focused:
		focused = value
		emit_signal("focus_changed", self, focused)

func is_focused() -> bool: return focused

func set_all_caps(value: bool):
	if all_caps != value:
		all_caps = value
		emit_signal("all_caps_changed")

func set_text(value: String):
	if text != value:
		text = value
		emit_signal("text_changed", text)

func get_text() -> String: 
	return text

func set_hidden(value: bool):
	if value != hidden:
		hidden = value
		emit_signal("hidden_changed")
func is_hidden() -> bool: return hidden

func set_disabled(value: bool):
	if value != disabled:
		disabled = value
		emit_signal("disabled_changed", value)

func is_disabled() -> bool:
	return disabled

func is_accessible() -> bool:
	return is_visible() && !is_disabled()

func get_button() -> Button:
	return _button

func set_hover_texture(value: Texture) -> void:
	if value != hover_texture:
		hover_texture = value
		emit_signal("hover_texture_changed")

func set_hover_texture_flags(value: int) -> void:
	if hover_texture_flags != value:
		hover_texture_flags = value
		emit_signal("hover_texture_flags_changed")

func is_class(value: String): return value == "MenuOptionsBase" or .is_class(value)
func get_class() -> String: return "MenuOptionsBase"

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
	
	_err = connect("hover_texture_flags_changed", self, "_on_hover_texture_flags_changed")
	_err = connect("disabled_changed", self, "_on_disabled_changed")
	_err = connect("focus_changed", self, "_on_focus_changed")
	_err = connect("text_changed", self, "_on_text_changed")
	_err = connect("all_caps_changed", self, "_update_text")
	_err = connect("gui_input", self, "_on_gui_input")
	_err = connect("hover_texture_changed", self, "_on_hover_texture_changed")
	
	set_text(text)
	
	if !Engine.editor_hint:
		_err = connect("hidden_changed", self, "_on_hidden_changed")
		_on_hidden_changed()
		emit_signal("focus_changed", self, is_focused())
	
	_on_disabled_changed(disabled)
	_on_hover_texture_flags_changed()
	_on_focus_changed(self, focused)
	_update_text()
	_on_hover_texture_changed()
	
	yield(get_tree(), "idle_frame")
	
	$HBoxContainer.set_pivot_offset($HBoxContainer.rect_size / 2.0)


#### LOGIC ####

func set_hover_icons_modulate(color: Color) -> void:
	for child in h_box_container.get_children():
		if child is TextureRect:
			child.set_modulate(color)


func _update_text() -> void:
	if all_caps:
		_button.set_text(text.to_upper())
	else:
		_button.set_text(text)

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
		$AnimationPlayer.play("Focused")


func _on_focus_exited():
	set_focused(false)


func _on_focus_changed(entity: Control, focus: bool) -> void:
	if !Engine.editor_hint:
		var button_focus_color = entity.get_color("font_color_hover", "Button")
		var dest_color = button_focus_color if focus else Color.transparent
		
		set_hover_icons_modulate(dest_color)
	
	if focused:
		_button.grab_focus()
	else:
		_button.release_focus()


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


func _on_disabled_changed(value: bool) -> void:
	_button.set_disabled(value)
	
	for sprite in hover_sprites:
		var alpha = int(!disabled)
		sprite.self_modulate.a = alpha


func _on_hover_texture_flags_changed():
	$HBoxContainer/HoverTexture.set_visible(hover_texture_flags & TEXTURE_FLAGS.LEFT)
	$HBoxContainer/HoverTexture2.set_visible(hover_texture_flags & TEXTURE_FLAGS.RIGHT)


func _on_text_changed(_text: String) -> void:
	_update_text()


func _on_hover_texture_changed() -> void:
	for sprite in hover_sprites:
		sprite.set_texture(hover_texture)
