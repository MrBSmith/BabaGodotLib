extends Behaviour
class_name ButtonBehaviour

enum STATE {
	NORMAL,
	HOVER,
	FOCUSED,
	PRESSED,
	TOGGLED,
	TOGGLED_FOCUSED,
	DISABLED
}

enum TOGGLE_MODE {
	NONE,
	SIMPLE_TOGGLE,
	RADIO
}

@export_group("Logic")
@export var toggle_mode : TOGGLE_MODE = TOGGLE_MODE.NONE
@export var state : STATE = STATE.NORMAL:
	set(value):
		if disabled:
			return
	
		if value != state:
			state = value
			state_changed.emit()
			
			if print_logs:
				print("%s changed state to: %s" % [get_parent().name, STATE.keys()[state]])
@export var print_logs : bool = false

@export var toggled : bool = false : 
	set(value):
		if value != toggled:
			toggled = value
			_update_state()
			toggled_changed.emit(toggled)

@export_group("Theme Handeling")
@export var modulate_based_on_theme : bool = false
@export var theme_class_override : String = ""

var mouse_inside : bool = false

var is_ready : bool = false

signal state_changed
signal pressed
signal toggled_changed(value)

#### ACCESSORS ####


#### BUILT-IN ####

func _ready() -> void:
	get_parent().mouse_entered.connect(_on_mouse_entered)
	get_parent().mouse_exited.connect(_on_mouse_exited)
	get_parent().focus_entered.connect(_on_focus_entered)
	get_parent().focus_exited.connect(_on_focus_exited)
	get_parent().gui_input.connect(_on_gui_input)
	get_parent().visibility_changed.connect(_on_visibility_changed)
	
	state_changed.connect(_update_theme)
	
	disabled_changed.connect(_on_disable_changed)
	
	is_ready = true
	
	if toggled:
		emit_signal("toggled")
		_update_state()


#### VIRTUALS ####



#### LOGIC ####

func get_state_name() -> String:
	return STATE.keys()[STATE.values().find(state)].to_lower()


func set_focused(value: int) -> void:
	if value:
		if state == STATE.TOGGLED:
			state = STATE.TOGGLED_FOCUSED
		else:
			state = STATE.FOCUSED
	else:
		state = STATE.NORMAL


func is_focused() -> bool:
	return state in [STATE.FOCUSED, STATE.TOGGLED_FOCUSED]


func _update_state() -> void:
	if disabled or is_focused():
		return
	
	if toggled:
		state = STATE.TOGGLED
	
	elif mouse_inside:
		state = STATE.HOVER
	
	else:
		state = STATE.NORMAL 


func _update_theme() -> void:
	if !modulate_based_on_theme:
		return
	
	var button = get_parent()
	var theme_class = theme_class_override if theme_class_override != "" else button.get_class()
	var color_name = "icon_%s_color" % get_state_name().to_lower()
	
	var color = button.get_theme_color(color_name, theme_class)
	button.set_self_modulate(color)



func toggle() -> void:
	if disabled:
		return
	
	if toggle_mode == TOGGLE_MODE.NONE:
		push_error("trying to toggle a non-togglable button, aborting")
		return
	
	toggled = !toggled
	
	if toggled && is_focused():
		state = STATE.TOGGLED_FOCUSED
	else:
		_update_state()
	
	emit_signal("toggled", toggled)




#### INPUTS ####



#### SIGNAL RESPONSES ####


func _on_gui_input(event: InputEvent) -> void:
	if Engine.is_editor_hint() or state == STATE.DISABLED or disabled:
		return
	
	if event.is_pressed(): 
		if event.is_action_pressed("ui_accept") or \
			(event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT):
			
			if toggle_mode == TOGGLE_MODE.NONE:
				state = STATE.PRESSED
			
			elif toggle_mode == TOGGLE_MODE.SIMPLE_TOGGLE or (toggle_mode == TOGGLE_MODE.RADIO && !toggled):
				toggle()
			
			else:
				return
			
			pressed.emit()
	
	else:
		if state == STATE.PRESSED:
			if event.is_action_released("ui_accept") or \
				(event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT):

				_update_state()


func _on_mouse_entered() -> void:
	if print_logs: print("mouse_entered")
	mouse_inside = true
	
	if not state in [STATE.DISABLED, STATE.TOGGLED, STATE.PRESSED] && ! is_focused():
		state = STATE.HOVER


func _on_mouse_exited() -> void:
	if print_logs: print("mouse_exited")
	mouse_inside = false
	
	if state == STATE.HOVER:
		_update_state()


func _on_focus_entered() -> void:
	if not state in [STATE.DISABLED, STATE.PRESSED] && !is_focused():
		match(state):
			STATE.TOGGLED: state = STATE.TOGGLED_FOCUSED
			_: state = STATE.FOCUSED


func _on_focus_exited() -> void:
	match(state):
		STATE.FOCUSED:
			state = STATE.NORMAL
		STATE.TOGGLED_FOCUSED:
			state = STATE.TOGGLED
		_:
			_update_state()


func _on_visibility_changed() -> void:
	_update_state()


func _on_disable_changed() -> void:
	_update_state()
