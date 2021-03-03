extends ListMenu
class_name ActionMenu

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

#### VIRTUALS ####



#### LOGIC ####

func _setup():
	yield(self, "ready")
	add_sub_menu(action_list)
	update_whole_display()
	
	for column in column_container.get_children():
		connect_menu_options(column, false)

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

func _on_menu_changed():
	if current_menu == menu_root && is_ready:
		EVENTS.emit_signal("action_choice_menu_entered")
