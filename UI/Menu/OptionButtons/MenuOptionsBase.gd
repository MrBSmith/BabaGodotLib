tool
extends Button
class_name MenuOptionsBase

signal disabled_changed(disabled)
signal focus_changed(entity, focus)
signal option_chose(menu_option)
signal hidden_changed

var is_ready : bool = false
var focused : bool = false setget set_focused, is_focused

export var hidden : bool = false setget set_hidden, is_hidden
export var all_caps : bool = false setget set_all_caps

#### ACCESSSORS ####

func set_focused(value: bool):
	if value != focused && !is_disabled():
		focused = value
		if focused: 
			grab_focus()
		if is_ready:
			emit_signal("focus_changed", self, focused)
func is_focused() -> bool: return focused

func set_all_caps(value: bool):
	all_caps = value
	if all_caps:
		text = text.to_upper()
	else:
		text = text.capitalize()

func set_text(value: String):
	if all_caps:
		text = value.to_upper()
	else:
		text = value

func set_hidden(value: bool):
	if value != hidden:
		hidden = value
		emit_signal("hidden_changed")
func is_hidden() -> bool: return hidden

func set_disabled(value: bool):
	if value != disabled:
		.set_disabled(value)
		emit_signal("disabled_changed", disabled)

#### BUILT-IN ####

func _ready() -> void:
	add_to_group("MenuOption")
	
	var _err = connect("focus_entered", self, "_on_focus_entered")
	_err = connect("focus_exited", self, "_on_focus_exited")
	_err = connect("pressed", self, "_on_pressed")
	_err = connect("gui_input", self, "_on_gui_input")
	_err = connect("mouse_entered", self, "_on_mouse_entered")
	_err = connect("mouse_exited", self, "_on_mouse_exited")
	
	var __ = connect("hidden_changed", self, "_on_hidden_changed")
	_on_hidden_changed()
	
	set_text(text)
	
	is_ready = true


#### LOGIC ####

func _on_gui_input(event : InputEvent): 
	if event.is_action_pressed("ui_accept") && is_focused():
		set_pressed(true)


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


func _on_hidden_changed() -> void:
	if hidden:
		set_modulate(Color.transparent)
	else:
		set_modulate(Color.white)
		
		if is_hovered() && !is_disabled():
			set_focused(true)
