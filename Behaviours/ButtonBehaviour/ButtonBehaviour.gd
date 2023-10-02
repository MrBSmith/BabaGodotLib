extends Behaviour
class_name ButtonBehaviour

enum STATE {
	NORMAL,
	HOVER,
	FOCUS,
	PRESSED,
	TOGGLED,
	TOGGLED_FOCUS,
	DISABLED,
	NONE
}

enum TOGGLE_MODE {
	NONE,
	SIMPLE_TOGGLE,
	RADIO
}

enum BUTTON_COLOR_MODE {
	NONE,
	MODULATE,
	SELF_MODULATE
}

const TOGGLED_STATES = [STATE.TOGGLED, STATE.TOGGLED_FOCUS]
const FOCUSED_STATES = [STATE.FOCUS, STATE.TOGGLED_FOCUS]

onready var logger: Node = get_node_or_null("%Logger")

export(TOGGLE_MODE) var toggle_mode : int = TOGGLE_MODE.NONE
export(STATE) var state : int = STATE.NORMAL setget set_state
export var print_logs : bool = false

export var theme_class : String = "Button"
export var theme_color_prefix : String = "font_color"

export(BUTTON_COLOR_MODE) var button_color_mode : int = BUTTON_COLOR_MODE.MODULATE
export var no_glow : bool = false

var defaut_focus_mode : int = Control.FOCUS_NONE

var previous_state : int = STATE.NONE
var theme : Theme 
var mouse_inside : bool = false

var is_ready : bool = false

signal state_changed
signal pressed
signal toggled(value)
signal focus_changed

#### ACCESSORS ####

func is_class(value: String): return value == "ButtonBehaviour" or .is_class(value)
func get_class() -> String: return "ButtonBehaviour"

func set_state(value: int) -> void:
	if disabled:
		return
	
	if value != state:
		previous_state = state
		state = value
		emit_signal("state_changed")
		
		if print_logs:
			print("%s changed state to: %s" % [get_parent().name, get_state_name()])
func get_state_name() -> String:
	return STATE.keys()[state]

func set_toggled(toggled: bool) -> void:
	if state == STATE.DISABLED:
		push_warning("Can't toggle a disabled button")
		return
	
	if toggled:
		if state == STATE.FOCUS:
			set_state(STATE.TOGGLED_FOCUS)
		else:
			set_state(STATE.TOGGLED)
	else:
		if state == STATE.TOGGLED_FOCUS:
			set_state(STATE.FOCUS)
		else:
			set_state(STATE.NORMAL)

func is_toggled() -> bool: return state in TOGGLED_STATES

func set_disabled(value: bool) -> void:
	if value != disabled:
		value = disabled
		
		if disabled:
			set_state(STATE.DISABLED)
		else:
			set_state(STATE.NORMAL)
func is_disabled() -> bool: return state == STATE.DISABLED or disabled

func set_focused(value: bool) -> void:
	if value != (state in FOCUSED_STATES):
		if value:
			if state == STATE.TOGGLED:
				set_state(STATE.TOGGLED_FOCUS)
			else:
				set_state(STATE.FOCUS)
		else:
			set_state(STATE.NORMAL)

func is_focused() -> bool: return state in FOCUSED_STATES

func is_pressed() -> bool:
	return state == STATE.PRESSED

#### BUILT-IN ####

func _ready() -> void:
	var __ = get_parent().connect("mouse_entered", self, "_on_mouse_entered")
	__ = get_parent().connect("mouse_exited", self, "_on_mouse_exited")
	__ = get_parent().connect("focus_entered", self, "_on_focus_entered")
	__ = get_parent().connect("focus_exited", self, "_on_focus_exited")
	__ = get_parent().connect("gui_input", self, "_on_gui_input")
	__ = get_parent().connect("visibility_changed", self, "_on_visibility_changed")
	__ = connect("state_changed", self, "_on_state_changed")
	
	is_ready = true
	
	if holder is Control:
		defaut_focus_mode = holder.focus_mode
	
	_update_theme()
	_on_state_changed()


#### VIRTUALS ####



#### LOGIC ####

func _update_theme() -> void:
	var theme_path = ProjectSettings.get_setting("gui/theme/custom")
	theme = load(theme_path)
	
	if holder is Control:
		var holder_theme = holder.get_theme()
		if holder_theme:
			theme = holder_theme
	
	if !theme and button_color_mode != BUTTON_COLOR_MODE.NONE:
		push_warning("Cannot modulate the holder: no theme to fetch colors from, please set the gui/theme/custom project setting to the wanted default game theme")


func _update_state() -> void:
	if is_disabled():
		return
	
	if state == STATE.NORMAL:
		if mouse_inside:
			set_state(STATE.HOVER)
		
		else:
			set_state(STATE.NORMAL) 


func toggle() -> void:
	if disabled:
		return
	
	if toggle_mode == TOGGLE_MODE.NONE:
		push_error("trying to toggle a non-togglable button, aborting")
		return
	
	set_toggled(!is_toggled())


#### INPUTS ####



#### SIGNAL RESPONSES ####


func _on_gui_input(event: InputEvent) -> void:
	if Engine.editor_hint or state == STATE.DISABLED or disabled:
		return
	
	if event.is_pressed(): 
		if event.is_action_pressed("ui_accept") or \
			(event is InputEventMouseButton && event.button_index == BUTTON_LEFT):
			
			if toggle_mode == TOGGLE_MODE.NONE:
				set_state(STATE.PRESSED)
			
			elif toggle_mode == TOGGLE_MODE.SIMPLE_TOGGLE or (toggle_mode == TOGGLE_MODE.RADIO && !is_toggled()):
				toggle()
			
			else:
				return
			
			emit_signal("pressed")
	
	else:
		if state == STATE.PRESSED:
			if event.is_action_released("ui_accept") or \
				(event is InputEventMouseButton && event.button_index == BUTTON_LEFT):

				_update_state()


func _on_mouse_entered() -> void:
	if print_logs: print("mouse_entered")
	mouse_inside = true
	
	if not state in [STATE.DISABLED, STATE.TOGGLED, STATE.PRESSED] && ! is_focused():
		set_state(STATE.HOVER)


func _on_mouse_exited() -> void:
	if print_logs: print("mouse_exited")
	mouse_inside = false
	
	if state == STATE.HOVER:
		_update_state()


func _on_focus_entered() -> void:
	if not state in [STATE.DISABLED, STATE.PRESSED] && !is_focused():
		match(state):
			STATE.TOGGLED: set_state(STATE.TOGGLED_FOCUS)
			_: set_state(STATE.FOCUS)


func _on_focus_exited() -> void:
	match(state):
		STATE.FOCUS:
			set_state(STATE.NORMAL)
		STATE.TOGGLED_FOCUS:
			set_state(STATE.TOGGLED)
		_:
			_update_state()


func _on_visibility_changed() -> void:
	_update_state()


func _on_state_changed() -> void:
	var previous_toggle = previous_state in TOGGLED_STATES
	var current_toggle = state in TOGGLED_STATES
	
	if previous_toggle != current_toggle:
		emit_signal("toggled", is_toggled())
	
	var previous_focused = previous_state in FOCUSED_STATES
	var current_focused = state in FOCUSED_STATES
	
	if previous_focused != current_focused:
		emit_signal("focus_changed", is_focused())
	
	if holder is Control:
		holder.focus_mode = Control.FOCUS_NONE if state == STATE.DISABLED else defaut_focus_mode
	
	if button_color_mode == BUTTON_COLOR_MODE.NONE or !theme:
		return
	
	var state_name = get_state_name().to_lower()
	
	var prefix = theme_color_prefix + "_" if !theme_color_prefix.empty() else ""
	var color_name = prefix + state_name if state_name != "normal" or prefix.empty() else theme_color_prefix
	if print_logs: print("theme_class: ", theme_class, " color_name: ", color_name)
	var color = theme.get_color(color_name, theme_class)
	
	if no_glow:
		color.r = clamp(color.r, 0.0, 1.0)
		color.g = clamp(color.g, 0.0, 1.0)
		color.b = clamp(color.b, 0.0, 1.0)
	
	if button_color_mode == BUTTON_COLOR_MODE.SELF_MODULATE:
		holder.set_self_modulate(color)
	else:
		holder.set_modulate(color)

