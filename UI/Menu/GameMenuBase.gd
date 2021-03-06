extends Control
class_name MenuBase

export var opt_container_path : String = "HBoxContainer/V_OptContainer"

onready var opt_container = get_node_or_null(opt_container_path)
onready var choice_sound_node = get_node_or_null("OptionChoiceSound")
onready var buttons_array : Array = []

var default_button_state : Array = []
var is_ready : bool = false

#### BUILT-IN ####

# Check the options when the scenes is ready, to get sure at least one of them is clickable
# Change the color of the option accordingly to their state
func _ready():
	is_ready = true
	_setup()



#### LOGIC ####


# This is called by _ready()
# This function exist so it can be overriden in children classes, unlike _ready
func _setup():
	connect_menu_options(opt_container)
	focus_first_option()


# Focus the first available option
func focus_first_option():
	for button in buttons_array:
		if !button.is_disabled():
			button.set_focused(true)
			break


# Connect the options in the menu 
# the wrapping argument determine if the cursor needs to wraps around 
# Going up on the first option put the focus on the last
# And going down on the last put the focus on the first
func connect_menu_options(option_container: Control, wrapping: bool = true):
	feed_buttons_array(option_container)
	
	if len(buttons_array) == 0:
		return
	
	var nb_buttons = buttons_array.size()
	var first_option_unabled : MenuOptionsBase = null
	var last_option_unabled : MenuOptionsBase = null
	
	# Find the first option unabled, and the last 
	for i in range(nb_buttons):
		if !buttons_array[i].is_disabled() && first_option_unabled == null:
			first_option_unabled = buttons_array[i]
		if !buttons_array[-i - 1].is_disabled() && last_option_unabled == null:
			last_option_unabled = buttons_array[-i - 1]
	
	# Setup the wrapping
	for i in range(nb_buttons):
		var button : Control = buttons_array[i]
		var prev_id = i - 1
		var previous_button = buttons_array[prev_id]
		
		while(previous_button.is_disabled()):
			prev_id -= 1
			previous_button = buttons_array[prev_id]
		
		var next_id =  wrapi(i + 1, 0, nb_buttons)
		var next_button = buttons_array[next_id]
		
		while(next_button.is_disabled()):
			next_id = wrapi(next_id + 1, 0, nb_buttons)
			next_button = buttons_array[next_id] 
		
		if button == first_option_unabled:
			if wrapping:
				button.set_focus_neighbour(MARGIN_TOP, previous_button.get_path())
		else:
			button.set_focus_previous(previous_button.get_path())
		
		if button == last_option_unabled:
			if wrapping:
				button.set_focus_neighbour(MARGIN_BOTTOM, next_button.get_path())
		else:
			button.set_focus_next(next_button.get_path())
		
		# Connect options signals
		var _err = button.connect("option_chose", self, "_on_menu_option_chose")
		_err = button.connect("focus_changed", self, "_on_menu_option_focus_changed")



func feed_buttons_array(option_container: Control):
	if option_container == null:
		return
	
	buttons_array = []
	for child in option_container.get_children():
		if child is Button:
			buttons_array.append(child)


# Stock the default state of every button
func load_default_buttons_state():
	for button in buttons_array:
		var button_state = button.is_disabled()
		default_button_state.append(button_state)


func set_buttons_disabled(value : bool):
	for button in buttons_array:
		button.set_disabled(value)


func set_buttons_default_state():
	for i in range(buttons_array.size()):
		buttons_array[i].set_disabled(default_button_state[i])


func navigate_sub_menu(menu: Control):
	get_parent().add_child(menu)
	queue_free()


#### VIRTUAL ####

func cancel():
	pass


#### INPUT ####

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		cancel()

#### SIGNAL RESPONSES ####

# When a button is aimed (with a mouse for exemple)
func _on_menu_option_focus_changed(_button : Button, focus: bool) -> void:
	if focus && choice_sound_node != null:
		choice_sound_node.play()

# Virtual method to respond to the signal emited by an option beeing chosen
# Here you can add the code that tells the game what to do based on what option was chose
func _on_menu_option_chose(_option) -> void:
	pass

