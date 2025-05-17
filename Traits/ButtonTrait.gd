extends Trait
class_name ButtonTrait

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

@export var toggle_mode : TOGGLE_MODE = TOGGLE_MODE.NONE
@export var theme_class : String = "Button"
@export var theme_color_prefix : String = "font_color"
@export var button_color_mode : BUTTON_COLOR_MODE = BUTTON_COLOR_MODE.MODULATE
@export var no_glow : bool = false
@export var state : STATE = STATE.NORMAL:
	set(value):
		if value != state:
			previous_state = state
			state = value
			state_changed.emit()

@export var disabled := false:
	set(value):
		if value != disabled:
			value = disabled
			
			if disabled:
				state = STATE.DISABLED
			else:
				state = STATE.NORMAL

var defaut_focus_mode : int = Control.FOCUS_NONE
var previous_state : STATE = STATE.NONE
var theme : Theme 
var mouse_inside : bool = false
var is_ready : bool = false

signal state_changed
signal pressed
signal toggled(value)
signal focus_changed

#### ACCESSORS ####

func get_state_name() -> String:
	return STATE.keys()[state]

func set_toggled(toggled: bool) -> void:
	if state == STATE.DISABLED:
		push_warning("Can't toggle a disabled button")
		return
	
	if toggled:
		if state in [STATE.FOCUS, STATE.TOGGLED_FOCUS]:
			state = STATE.TOGGLED_FOCUS
		else:
			state = STATE.TOGGLED
	else:
		if state in [STATE.TOGGLED_FOCUS, STATE.FOCUS]:
			state = STATE.FOCUS
		else:
			state = STATE.NORMAL

func is_toggled() -> bool: return state in TOGGLED_STATES

func set_focused(value: bool) -> void:
	if value != (state in FOCUSED_STATES):
		if value:
			if state == STATE.TOGGLED:
				state = STATE.TOGGLED_FOCUS
			else:
				state = STATE.FOCUS
		else:
			state = STATE.NORMAL

func is_focused() -> bool: return state in FOCUSED_STATES

func is_pressed() -> bool:
	return state == STATE.PRESSED

#### BUILT-IN ####

func _ready() -> void:
	holder.mouse_entered.connect(_on_mouse_entered)
	holder.mouse_exited.connect(_on_mouse_exited)
	holder.focus_entered.connect(_on_focus_entered)
	holder.focus_exited.connect(_on_focus_exited)
	holder.gui_input.connect(_on_gui_input)
	holder.visibility_changed.connect(_on_visibility_changed)
	
	state_changed.connect(_on_state_changed)
	
	is_ready = true
	
	if holder is Control:
		defaut_focus_mode = holder.focus_mode
	
	_update_theme()
	_on_state_changed()
	_update_focus_mode()


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
	if disabled:
		return
	
	if state == STATE.NORMAL:
		if mouse_inside:
			state = STATE.HOVER
		
		else:
			state = STATE.NORMAL 


func _update_focus_mode() -> void:
	if not holder is Control:
		return
	
	var focus_mode = Control.FOCUS_ALL if !disabled and state != STATE.DISABLED and holder.is_visible_in_tree() else Control.FOCUS_NONE
	holder.set_focus_mode(focus_mode)


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
	if Engine.is_editor_hint() or state == STATE.DISABLED or disabled:
		return
	
	if event.is_pressed(): 
		if event.is_action_pressed("ui_accept") or \
			(event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):
			
			if toggle_mode == TOGGLE_MODE.NONE:
				state = STATE.PRESSED
			
			elif toggle_mode == TOGGLE_MODE.SIMPLE_TOGGLE or (toggle_mode == TOGGLE_MODE.RADIO && !is_toggled()):
				toggle()
			
			else:
				return
			
			emit_signal("pressed")
	
	else:
		if state == STATE.PRESSED:
			if event.is_action_released("ui_accept") or \
				(event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):
				
				if toggle_mode == TOGGLE_MODE.NONE && state == STATE.PRESSED:
					state = STATE.FOCUS
				else:
					_update_state()


func _on_mouse_entered() -> void:
	mouse_inside = true
	
	if not state in [STATE.DISABLED, STATE.TOGGLED, STATE.PRESSED] and !is_focused():
		state = STATE.HOVER


func _on_mouse_exited() -> void:
	mouse_inside = false
	
	if state == STATE.HOVER:
		_update_state()


func _on_focus_entered() -> void:
	if not state in [STATE.DISABLED, STATE.PRESSED] && !is_focused():
		match(state):
			STATE.TOGGLED: state = STATE.TOGGLED_FOCUS
			_: state = STATE.FOCUS


func _on_focus_exited() -> void:
	match(state):
		STATE.FOCUS:
			state = STATE.NORMAL
		STATE.TOGGLED_FOCUS:
			state = STATE.TOGGLED
		_:
			_update_state()


func _on_visibility_changed() -> void:
	_update_state()
	_update_focus_mode()


func _on_state_changed() -> void:
	var previous_toggle = previous_state in TOGGLED_STATES
	var current_toggle = state in TOGGLED_STATES
	
	if previous_toggle != current_toggle:
		toggled.emit(is_toggled())
	
	var previous_focused = previous_state in FOCUSED_STATES
	var current_focused = state in FOCUSED_STATES
	
	if previous_focused != current_focused:
		focus_changed.emit(is_focused())
	
	if holder is Control:
		holder.focus_mode = Control.FOCUS_NONE if state == STATE.DISABLED else defaut_focus_mode
	
	if button_color_mode == BUTTON_COLOR_MODE.NONE or !theme:
		return
	
	var state_name = get_state_name().to_lower()
	
	var prefix : String = theme_color_prefix + "_" if !theme_color_prefix.is_empty() else ""
	var color_name : String = prefix + state_name if state_name != "normal" or prefix.is_empty() else theme_color_prefix
	var color = theme.get_color(color_name, theme_class)
	
	if no_glow:
		color.r = clamp(color.r, 0.0, 1.0)
		color.g = clamp(color.g, 0.0, 1.0)
		color.b = clamp(color.b, 0.0, 1.0)
	
	if button_color_mode == BUTTON_COLOR_MODE.SELF_MODULATE:
		holder.set_self_modulate(color)
	else:
		holder.set_modulate(color)
