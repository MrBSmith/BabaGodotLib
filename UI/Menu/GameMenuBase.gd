extends Control
class_name MenuBase

enum CANCEL_ACTION {
	GO_TO_LAST_MENU,
	RESUME_GAME,
	NONE
}

export var opt_container_path : String = "VBoxContainer"

onready var opt_container = get_node_or_null(opt_container_path)
onready var choice_sound_node = get_node_or_null("OptionChoiceSound")

export(CANCEL_ACTION) var cancel_action = CANCEL_ACTION.GO_TO_LAST_MENU 
export var focus_first_option_on_ready : bool = true

var default_button_state : Array = []
var is_ready : bool = false

var submenu : bool = false setget set_submenu, is_submenu

#warning-ignore:unused_signal
signal sub_menu_left

#### ACCESSORS ####

func set_submenu(value: bool) -> void: submenu = value
func is_submenu() -> bool: return submenu


#### BUILT-IN ####

# Check the options when the scenes is ready, to get sure at least one of them is clickable
# Change the color of the option accordingly to their state
func _ready():
	is_ready = true
	EVENTS.emit_signal("menu_entered", name)
	_setup()


#### LOGIC ####

# This is called by _ready()
# This function exist so it can be overriden in children classes, unlike _ready
func _setup():
	_update_options()
	
	if focus_first_option_on_ready:
		focus_first_option()


func _update_options() -> void:
	_setup_menu_options_wrapping()
	_connect_options_signals()


# Focus the first available option
func focus_first_option() -> void:
	if !is_instance_valid(opt_container):
		return
	
	for button in opt_container.get_children():
		if !button.is_disabled():
			button.set_focused(true)
			break


# Connect the options in the menu 
# the wrapping argument determine if the cursor needs to wraps around 
# Going up on the first option put the focus on the last
# And going down on the last put the focus on the first
func _setup_menu_options_wrapping(wrapping: bool = true):
	var menu_options_array = _fetch_menu_option_array()
	var nb_options = menu_options_array.size()
	var first_option_unabled : MenuOptionsBase = null
	var last_option_unabled : MenuOptionsBase = null
	
	# Find the first option unabled, and the last 
	for i in range(nb_options):
		if menu_options_array[i].is_accessible() && first_option_unabled == null:
			first_option_unabled = menu_options_array[i]
		
		if menu_options_array[-i - 1].is_accessible() && last_option_unabled == null:
			last_option_unabled = menu_options_array[-i - 1]
	
	# Setup the wrapping
	for i in range(nb_options):
		var option = menu_options_array[i]
		var button : Button = menu_options_array[i].get_button()
		
		if option.is_disabled() or !option.is_visible():
			continue
		
		var prev_id = i - 1
		var previous_option = menu_options_array[prev_id]
		
		while(!previous_option.is_accessible()):
			prev_id -= 1
			previous_option = menu_options_array[prev_id]
		
		var previous_button = previous_option.get_button()
		
		var next_id =  wrapi(i + 1, 0, nb_options)
		var next_option = menu_options_array[next_id]
		
		while(!next_option.is_accessible()):
			next_id = wrapi(next_id + 1, 0, nb_options)
			next_option = menu_options_array[next_id]
		
		var next_button = next_option.get_button()
		
		if button == first_option_unabled:
			if wrapping:
				button.set_focus_neighbour(MARGIN_TOP, previous_button.get_path())
		else:
			button.set_focus_neighbour(MARGIN_TOP, previous_button.get_path())
			button.set_focus_previous(previous_button.get_path())
		
		if button == last_option_unabled:
			if wrapping:
				button.set_focus_neighbour(MARGIN_BOTTOM, next_button.get_path())
		else:
			button.set_focus_neighbour(MARGIN_BOTTOM, next_button.get_path())
			button.set_focus_next(next_button.get_path())


func _connect_options_signals() -> void:
	for option in get_tree().get_nodes_in_group("MenuOption"):
		if !option.is_connected("focus_changed", self, "_on_menu_option_focus_changed"):
			var _err = option.connect("focus_changed", self, "_on_menu_option_focus_changed")
	
	if opt_container == null:
		return
	
	# Connect options signals
	for button in opt_container.get_children():
		if not button is MenuOptionsBase:
			continue
		
		var _err = button.connect("option_chose", self, "_on_menu_option_chose")
		_err = button.connect("disabled_changed", self, "_on_menu_option_disabled_changed")
		_err = button.connect("visibility_changed", self, "_on_menu_option_visible_changed")


func _fetch_menu_option_array() -> Array:
	if !is_instance_valid(opt_container):
		return []
	
	var menu_option_array = []
	for child in opt_container.get_children():
		if child is MenuOptionsBase:
			menu_option_array.append(child)
	
	return menu_option_array

# Stock the default state of every button
func load_default_buttons_state():
	for button in _fetch_menu_option_array():
		var button_state = button.is_disabled()
		default_button_state.append(button_state)


func set_buttons_disabled(value : bool):
	for button in _fetch_menu_option_array():
		button.set_disabled(value)


func set_buttons_default_state():
	var menu_options_array = _fetch_menu_option_array()
	for i in range(menu_options_array.size()):
		menu_options_array[i].set_disabled(default_button_state[i])


func _go_to_last_menu() -> void:
	if self == get_tree().get_current_scene():
		EVENTS.emit_signal("navigate_menu_back_query", null, self)
	else:
		EVENTS.emit_signal("navigate_menu_back_query", get_parent(), self)


func _resume_game():
	EVENTS.emit_signal("game_resumed")
	get_tree().set_pause(false)
	queue_free()


func cancel():
	match(cancel_action):
		CANCEL_ACTION.RESUME_GAME:
			_resume_game()
		CANCEL_ACTION.GO_TO_LAST_MENU:
			_go_to_last_menu()


#### INPUT ####

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		cancel()


#### SIGNAL RESPONSES ####

# When a button is aimed (with a mouse for exemple)
func _on_menu_option_focus_changed(_button : Control, focus: bool) -> void:
	if focus && choice_sound_node != null:
		choice_sound_node.play()

# Virtual method to respond to the signal emited by an option beeing chosen
# Here you can add the code that tells the game what to do based on what option was chose
func _on_menu_option_chose(_option: MenuOptionsBase) -> void:
	pass


func _on_menu_option_disabled_changed(_disabled: bool) -> void:
	_setup_menu_options_wrapping()


func _on_menu_option_visible_changed() -> void:
	_setup_menu_options_wrapping()
