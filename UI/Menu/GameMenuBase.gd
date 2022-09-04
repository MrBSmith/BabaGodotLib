extends Control
class_name MenuBase

enum CANCEL_ACTION {
	GO_TO_LAST_MENU,
	RESUME_GAME,
	NONE
}

export var menu_option_scene : PackedScene
export var screen_title_option_base : PackedScene

export var opt_container_path : String = "VBoxContainer"

onready var opt_container = get_node_or_null(opt_container_path)
onready var choice_sound_node = get_node_or_null("OptionChoiceSound")

onready var options_array = _fetch_menu_option_array() setget set_options_array

export(CANCEL_ACTION) var cancel_action = CANCEL_ACTION.GO_TO_LAST_MENU 
export var focus_first_option_on_ready : bool = true

var default_button_state : Array = []
var is_ready : bool = false

var submenu : bool = false setget set_submenu, is_submenu

#warning-ignore:unused_signal
signal menu_left
#warning-ignore:unused_signal
signal sub_menu_left
signal options_array_changed

#### ACCESSORS ####

func set_submenu(value: bool) -> void: submenu = value
func is_submenu() -> bool: return submenu


func set_options_array(value: Array) -> void:
	if options_array != value:
		options_array = value
		emit_signal("options_array_changed", options_array)


#### BUILT-IN ####

# Check the options when the scenes is ready, to get sure at least one of them is clickable
# Change the color of the option accordingly to their state
func _ready() -> void:
	is_ready = true
	var __ = connect("options_array_changed", self, "_on_options_array_changed")
	
	EVENTS.emit_signal("menu_entered", name)
	_setup()


#### LOGIC ####

# This is called by _ready()
# This function exist so it can be overriden in children classes, unlike _ready
func _setup() -> void:
	_update_options()
	
	if focus_first_option_on_ready:
		focus_first_option()


func _update_options() -> void:
	_setup_menu_options_wrapping()
	_connect_options_signals()

# To be override so we can dynamically instantiate new options buttons instead of instanciating
# Them directly into the optioncontainer of the scene
# This method should be called in the _setup() method of the menu
# So that all buttons have signals connected at the end
func _instantiate_options() -> void:
	pass

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
func _setup_menu_options_wrapping(wrapping: bool = true) -> void:
	var nb_options = options_array.size()
	var first_option_unabled : MenuOptionsBase = null
	var last_option_unabled : MenuOptionsBase = null
	
	# Find the first option unabled, and the last 
	for i in range(nb_options):
		if options_array[i].is_accessible() && first_option_unabled == null:
			first_option_unabled = options_array[i]
		
		if options_array[-i - 1].is_accessible() && last_option_unabled == null:
			last_option_unabled = options_array[-i - 1]
	
	# Setup the wrapping
	for i in range(nb_options):
		var option = options_array[i]
		var button : Button = options_array[i].get_button()
		
		if option.is_disabled() or !option.is_visible():
			continue
		
		var prev_id = i - 1
		var previous_option = options_array[prev_id]
		
		while(!previous_option.is_accessible()):
			prev_id -= 1
			previous_option = options_array[prev_id]
		
		var previous_button = previous_option.get_button()
		
		var next_id =  wrapi(i + 1, 0, nb_options)
		var next_option = options_array[next_id]
		
		while(!next_option.is_accessible()):
			next_id = wrapi(next_id + 1, 0, nb_options)
			next_option = options_array[next_id]
		
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
	for button in options_array:
		if not button is MenuOptionsBase:
			continue
		
		if !button.is_connected("option_chose", self, "_on_menu_option_chose"):
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


# instantiate a new menu option to the option container, below another option
# or directly in child of the optioncontainer.
# Specify : menu option base scene, upper node name, hidden, all caps, text and disabled
# !new_button_text parameter can contains spaces!
func _instantiate_new_menu_button(option_scene : PackedScene = null,\
								option_upper_node_name : String = "",\
								new_button_hidden : bool = true,\
								new_button_allcaps : bool = false,\
								new_button_text : String = "",\
								new_button_disabled : bool = false) -> void:
	if new_button_text != "":
		var new_button = option_scene.instance()
		
		# set name of the button by replacing spaces with void character (" " => "")
		# so that there is no space in the tree, but correctly displayed with spaces in game
		new_button.set_name(new_button_text.replacen(" ", ""))
		
		new_button.hidden = new_button_hidden
		new_button.all_caps = new_button_allcaps
		new_button.text = new_button_text
		new_button.disabled = new_button_disabled
		
		# the node which will be on top of our new button
		var option_upper_node : MarginContainer = opt_container.get_node_or_null(option_upper_node_name)\
												if option_upper_node_name != "" else null
		
		if is_instance_valid(option_upper_node):
			opt_container.add_child_below_node(option_upper_node, new_button, true)
		else:
			opt_container.add_child(new_button, true)
	else:
		push_error("Did not specify any name/text for the instantiation of new_button")

# Stock the default state of every button
func load_default_buttons_state():
	for button in _fetch_menu_option_array():
		var button_state = button.is_disabled()
		default_button_state.append(button_state)


func set_buttons_disabled(value : bool):
	for button in _fetch_menu_option_array():
		button.set_disabled(value)


func set_buttons_default_state():
	for i in range(options_array.size()):
		options_array[i].set_disabled(default_button_state[i])


func _go_to_last_menu() -> void:
	if self == get_tree().get_current_scene():
		EVENTS.emit_signal("navigate_menu_back_query")
	else:
		EVENTS.emit_signal("navigate_menu_back_query")


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
	_update_options()


func _on_options_array_changed(_array: Array) -> void:
	_update_options()
