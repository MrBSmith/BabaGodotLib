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

@export_enum(TOGGLE_MODE) var toggle_mode : int = TOGGLE_MODE.NONE
@export_enum(STATE) var state : int = STATE.NORMAL:
	set(value):
		if disabled:
			return
	
		if value != state:
			state = value
			emit_signal("state_changed")
			
			if print_logs:
				print("%s changed state to: %s" % [get_parent().name, STATE.keys()[state]])
				print_stack()
@export var print_logs : bool = false

@export var toggled : bool = false : 
	set(value):
		if value != toggled:
			toggled = value
			_update_state()
			toggled_changed.emit(toggled)


var mouse_inside : bool = false

var is_ready : bool = false

signal state_changed
signal pressed
signal toggled_changed(value)

#### ACCESSORS ####

func is_class(value: String): return value == "ButtonBehaviour" or super.is_class(value)
func get_class() -> String: return "ButtonBehaviour"


#### BUILT-IN ####

func _ready() -> void:
	var __ = get_parent().connect("mouse_entered", _on_mouse_entered)
	__ = get_parent().connect("mouse_exited", _on_mouse_exited)
	__ = get_parent().connect("focus_entered", _on_focus_entered)
	__ = get_parent().connect("focus_exited", _on_focus_exited)
	__ = get_parent().connect("gui_input", _on_gui_input)
	__ = get_parent().connect("visibility_changed", _on_visibility_changed)
	
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
			
			emit_signal("pressed")
	
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
