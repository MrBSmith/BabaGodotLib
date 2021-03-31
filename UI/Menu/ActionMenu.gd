tool
extends ListMenu
class_name ActionMenu

const list_menu_scene = preload("res://BabaGodotLib/UI/Menu/ListMenu.tscn") 

onready var window_node = $ResizableWindow
onready var initial_size = rect_size
onready var submenu_size = rect_size * 1.5

export var window_texture : Texture = null setget set_window_texture
export var options_appear_delay : float = 0.2

var timer_node : Timer = null
var description_instance : DescriptionWindow = null

var action_list : Array = [
	"Move",
	"Attack",
	"Skill",
	"Item",
	"Wait"
]

#### ACCESSORS ####

func is_class(value: String): return value == "ActionMenu" or .is_class(value)
func get_class() -> String: return "ActionMenu"

func set_window_texture(value: Texture):
	if !is_ready:
		yield(self, "ready")
	
	window_texture = value
	window_node.set_texture(value)


#### BUILT-IN ####

func _ready() -> void:
	var __ = EVENTS.connect("update_unabled_actions", self, "_on_update_unabled_actions")
	__ = EVENTS.connect("add_action_submenu", self, "_on_add_action_submenu")
	__ = window_node.connect("resize_animation_finished", self, "_on_window_resize_animation_finished")
	__ = EVENTS.connect("target_choice_state_entered", self, "_on_target_choice_state_entered")
	__ = EVENTS.connect("option_choice_state_entered", self, "_on_option_choice_state_entered")
	timer_node = Timer.new()
	add_child(timer_node)




#### VIRTUALS ####

func _setup():
	if Engine.editor_hint:
		return
	
	yield(self, "ready")
	var option_array = []
	
	for string in action_list:
		var option_data_container = OptionDataContainer.new(null, string, int(INF), null)
		option_array.append(option_data_container)
	
	add_sub_menu(option_array)
	_update_whole_display()
	
	for column in column_container.get_children():
		connect_menu_options(column, false)
	
	for option in get_every_options():
		option.set_visible(true)
	
	yield(get_tree(), "idle_frame")
	_on_menu_resized()


#### LOGIC ####

func option_appear_animation():
	var options_array = get_every_options()
	
	for i in range(options_array.size()):
		var option = options_array[i]
		if option == null:
			continue
		
		timer_node.start(options_appear_delay)
		yield(timer_node, "timeout")
		
		if option == null:
			continue
		option.appear()


func instanciate_option(data_container: OptionDataContainer) -> Button:
	var option = menu_option_scene.instance()
	option.set_text(data_container.name)
	option.set_amount(data_container.amount)
	option.set_icon_texture(data_container.icon_texture)
	
	return option


func generate_submenu():
	var new_menu = list_menu_scene.instance()
	
	add_child(new_menu)


func set_option_all_caps(value: bool):
	for option in get_every_options():
		option.set_all_caps(value)
	
	yield(get_tree(), "idle_frame")
	
	for column in column_container.get_children():
		column.set_margin(MARGIN_LEFT, 0.0) 


func disable_every_actions(value: bool):
	for option in column_container.get_child(0).get_children():
		option.set_disabled(value)


func destroy_description_window():
	if description_instance != null:
		description_instance.queue_free()


#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_update_unabled_actions(move: bool, attack: bool, item : bool, skill: bool, wait: bool):
	if current_menu == menu_root && are_all_columns_empty():
		yield(self, "option_update_finished")
	
	find_option("Move").set_disabled(!move)
	find_option("Attack").set_disabled(!attack)
	find_option("Item").set_disabled(!item)
	find_option("Skill").set_disabled(!skill)
	find_option("Wait").set_disabled(!wait)


func _on_add_action_submenu(data_array: Array, menu_name: String):
	var menu = find_sub_menu(menu_name)
	add_sub_menu(data_array, menu)


func _on_menu_changed(menu):
	if !is_ready:
		yield(self, "ready")
	
	if menu == menu_root:
		EVENTS.emit_signal("action_choice_menu_entered")
		window_node.trigger_resize_animation(initial_size, CORNER_TOP_LEFT)
		destroy_description_window()
	else:
		window_node.trigger_resize_animation(submenu_size, CORNER_TOP_LEFT)
	
	if window_node.is_resizing:
		yield(window_node, "resize_animation_finished")
	
	if menu != menu_root:
		set_option_all_caps(false)
	
	option_appear_animation()


func _on_option_chose(option: MenuOptionsBase):
	if current_menu == menu_root:
		EVENTS.emit_signal("actor_action_chosen", option.text.capitalize())
	else:
		
		var option_data_container = get_data_container(current_menu, option.name)
		if option_data_container == null:
			return
		
		var data_container_obj_ref = option_data_container.object_ref
		if data_container_obj_ref == null:
			return
		
		match(current_menu.name):
			"Skill": EVENTS.emit_signal("skill_chosen", data_container_obj_ref)
			"Item": EVENTS.emit_signal("item_chosen", data_container_obj_ref)



func _on_option_focus_changed(option: Control, focused: bool):
	if option == null: return
	
	if focused:
		var data_container : OptionDataContainer = get_data_container(current_menu, option.name)
		
		if data_container == null:
			print("The given option: " + option.get_name() + " data container couldn't be found")
		
		var obj_ref = data_container.object_ref
		
		if obj_ref == null: return
		
		description_instance = description_window_scene.instance()
		var descritpion_data = obj_ref.fetch_description_data()
		
		add_child(description_instance)
		
		description_instance.feed(descritpion_data)
		
		var window_size = initial_size * 2
		var top_left_corner = $ResizableWindow.get_top_left_corner()
		
		description_instance.set_size(window_size)
		description_instance.set_position(top_left_corner + Vector2(-window_size.x - 4, 0))
		
	else:
		if description_instance != null:
			description_instance.queue_free()


func _on_window_resize_animation_finished():
	_update_columns_size()


func _on_option_choice_state_entered():
	disable_every_actions(false)

func _on_target_choice_state_entered():
	disable_every_actions(true)
	destroy_description_window()
