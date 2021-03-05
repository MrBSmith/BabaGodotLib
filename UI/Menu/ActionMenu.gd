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
	add_sub_menu(action_list)
	_update_whole_display()
	
	for column in column_container.get_children():
		connect_menu_options(column, false)
	
	for option in get_every_options():
		option.set_visible(true)


func connect_action_options():
	var options_array = get_every_options()
	
	for option in options_array:
		option.connect("option_chose", self, "_on_option_chose")


func option_appear_animation():
	var options_array = get_every_options()
	var nb_options = options_array.size()
	
	for i in range(nb_options):
		var option = options_array[i]
		if option == null:
			continue
		
		option.set_visible(true)
		timer_node.start(options_appear_delay)
		
		if i < nb_options - 1:
			yield(timer_node, "timeout")


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
		
		connect_action_options()
	
	option_appear_animation()


func _on_option_chose(option):
	if current_menu == menu_root:
		EVENTS.emit_signal("actor_action_chosen", option.name)
