extends ListMenu
class_name ActionMenu

export var options_appear_delay : float = 0.2

var timer_node : Timer = null

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


#### BUILT-IN ####

func _ready() -> void:
	var __ = EVENTS.connect("update_unabled_actions", self, "_on_update_unabled_actions")
	__ = EVENTS.connect("disable_every_actions", self, "_on_disable_every_actions")
	__ = EVENTS.connect("add_action_submenu", self, "_on_add_action_submenu")
	
	timer_node = Timer.new()
	add_child(timer_node)




#### VIRTUALS ####



#### LOGIC ####

func _setup():
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


#func connect_action_options():
#	var options_array = get_every_options()
#
#	for option in options_array:
#		option.connect("option_chose", self, "_on_option_chose")


func option_appear_animation():
	var options_array = get_every_options()
	
	for i in range(options_array.size()):
		var option = options_array[i]
		if option == null:
			continue
		
		timer_node.start(options_appear_delay)
		yield(timer_node, "timeout")
		
		option.appear()


func instanciate_option(data_container: OptionDataContainer) -> Button:
	var option = menu_option_scene.instance()
	option.set_text(data_container.name)
	option.set_amount(data_container.amount)
	option.set_icon_texture(data_container.icon_texture)
	
	return option

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


func _on_disable_every_actions():
	for option in column_container.get_child(0).get_children():
		option.set_disabled(true)


func _on_add_action_submenu(data_array: Array, menu_name: String):
	var menu = find_sub_menu(menu_name)
	add_sub_menu(data_array, menu)


func _on_menu_changed(menu):
	if menu == menu_root && is_ready:
		EVENTS.emit_signal("action_choice_menu_entered")
		
#		connect_action_options()
	
	option_appear_animation()


func _on_option_chose(option):
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
