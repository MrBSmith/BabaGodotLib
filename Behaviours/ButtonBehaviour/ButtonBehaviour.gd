extends Behaviour
class_name ButtonBehaviour

enum STATE {
	NORMAL,
	HOVER,
	FOCUSED,
	PRESSED,
	TOGGLED,
	DISABLED
}

enum TOGGLE_MODE {
	NONE,
	SIMPLE_TOGGLE,
	RADIO
}

export(TOGGLE_MODE) var toggle_mode : int = TOGGLE_MODE.NONE
export(STATE) var state : int = STATE.NORMAL setget set_state
export var print_logs : bool = false

export var toggled : bool = false

var mouse_inside : bool = false

signal state_changed
signal pressed
signal toggled(value)

#### ACCESSORS ####

func is_class(value: String): return value == "ButtonBehaviour" or .is_class(value)
func get_class() -> String: return "ButtonBehaviour"

func set_state(value: int) -> void:
	if disabled:
		return
	
	if value != state:
		state = value
		emit_signal("state_changed")


#### BUILT-IN ####

func _ready() -> void:
	var __ = get_parent().connect("mouse_entered", self, "_on_mouse_entered")
	__ = get_parent().connect("mouse_exited", self, "_on_mouse_exited")
	__ = get_parent().connect("focus_entered", self, "_on_focus_entered")
	__ = get_parent().connect("focus_exited", self, "_on_focus_exited")
	__ = get_parent().connect("gui_input", self, "_on_gui_input")
	__ = get_parent().connect("visibility_changed", self, "_on_visibility_changed")
	
	if toggled:
		emit_signal("toggled")
		_update_state()


#### VIRTUALS ####



#### LOGIC ####


func _update_state() -> void:
	if disabled:
		return
	
	if toggled:
		set_state(STATE.TOGGLED)
	
	elif get_parent().get_focus_owner() == get_parent():
		set_state(STATE.FOCUSED)
	
	elif mouse_inside:
		set_state(STATE.HOVER)
	
	else:
		set_state(STATE.NORMAL) 


func toggle() -> void:
	if disabled:
		return
	
	if toggle_mode == TOGGLE_MODE.NONE:
		push_error("trying to toggle a non-togglable button, aborting")
		return
	
	toggled = !toggled
	
	_update_state()
	emit_signal("toggled", toggled)


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
			
			elif toggle_mode == TOGGLE_MODE.SIMPLE_TOGGLE or (toggle_mode == TOGGLE_MODE.RADIO && !toggled):
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
	
	if not state in [STATE.DISABLED, STATE.TOGGLED, STATE.PRESSED]:
		set_state(STATE.HOVER)
		mouse_inside = true


func _on_mouse_exited() -> void:
	if print_logs: print("mouse_exited")

	if state == STATE.HOVER:
		mouse_inside = false
		_update_state()


func _on_focus_entered() -> void:
	if not state in [STATE.DISABLED, STATE.TOGGLED, STATE.PRESSED]:
		set_state(STATE.FOCUSED)


func _on_focus_exited() -> void:
	if state == STATE.FOCUSED:
		_update_state()


func _on_visibility_changed() -> void:
	_update_state()
