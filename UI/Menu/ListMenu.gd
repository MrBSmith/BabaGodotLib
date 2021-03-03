extends MenuBase
class_name ListMenu

export var menu_option_scene_path : String = "res://BabaGodotLib/UI/Menu/MenuOptionBase.tscn"
export var option_v_separation : int = INF 

onready var menu_root = $MenuRoot
onready var column_container = $HBoxContainer
onready var menu_option_scene = load(menu_option_scene_path)
onready var current_menu = menu_root setget set_current_menu, get_current_menu

export var max_lines : int = 3 setget set_max_lines, get_max_lines
export var max_columns : int = 2 setget set_max_columns, get_max_columns

var current_top_line : int = 0

signal option_table_size_changed()
signal update_column_finished()
signal option_update_finished()
signal menu_changed()

#### ACCESSORS ####

func is_class(value: String): return value == "ListMenu" or .is_class(value)
func get_class() -> String: return "ListMenu"

func set_max_lines(value: int): 
	if value > 0 && value != max_lines:
		max_lines = value
		if is_ready:
			emit_signal("option_table_size_changed")

func get_max_lines() -> int: return max_lines

func set_max_columns(value: int):
	if value > 0 && value != max_columns:
		max_columns = value
		if is_ready:
			emit_signal("option_table_size_changed")

func get_max_columns() -> int: return max_columns

func set_current_menu(menu: Node):
	if menu_root.is_a_parent_of(menu) or menu == menu_root:
		current_menu = menu
		clear_options()
		update_whole_display()
		
		emit_signal("menu_changed")

func get_current_menu() -> Node: return current_menu

#### BUILT-IN ####

func _ready() -> void:
	var __ = connect("option_table_size_changed", self, "_on_option_table_size_changed")
	__ = connect("menu_changed", self, "_on_menu_changed")

#### VIRTUALS ####



#### LOGIC ####


func _setup():
	yield(self, "ready")
	update_whole_display()
	
	for column in column_container.get_children():
		connect_menu_options(column, false)


func add_sub_menu(data_array: Array, menu: Node = menu_root):
	for string in data_array:
		var option = OptionDataContainer.new(string)
		menu.add_child(option)
	
	set_current_menu(menu)


func update_whole_display():
	var result = update_columns()
	if result is GDScriptFunctionState:
		yield(self, "update_column_finished")
	
	update_options()


func update_columns():
	var nb_column = column_container.get_child_count()
	if nb_column > max_columns:
		var column_excess = nb_column - max_columns
		for _i in range(column_excess):
			var last_column = column_container.get_child(get_child_count() - 1)
			last_column.queue_free()
			yield(last_column, "tree_exited")
	else:
		for i in range(max_columns):
			if i + 1 > nb_column:
				var column = VBoxContainer.new()
				column_container.add_child(column)
				column.set_margin(MARGIN_BOTTOM, 0.0)
				column.add_constant_override("separation", option_v_separation)
				nb_column += 1
	
	emit_signal("update_column_finished")


func update_options():
	var last_added_option : Button = null
	var data_array = current_menu.get_children()
	
	for i in data_array.size():
		var column_id = i % max_columns
		
		var obj_name = data_array[i].get_name()
		var column = column_container.get_child(column_id)
		
		var option_already_displayed = find_option(obj_name)
		var in_correct_column = false
		
		if option_already_displayed != null:
			var option_column = option_already_displayed.get_parent()
			in_correct_column = option_column.get_index() == column_id
		
		# Remove useless or missplaced options
		if !must_option_be_displayed(i) or !in_correct_column:
			if option_already_displayed != null:
				option_already_displayed.queue_free()
				yield(option_already_displayed, "tree_exited")
		
		# Add needed options
		if must_option_be_displayed(i):
			if option_already_displayed == null or !option_already_displayed.is_inside_tree():
				var option = menu_option_scene.instance()
				option.set_text(obj_name)
				
				column.add_child(option)
				option.owner = self
				option.set_name(obj_name.capitalize())
				last_added_option = option
				
				var line = get_option_relative_line(i)
				if line != max_lines - 1:
					column.move_child(option, line)
	
	if last_added_option != null:
		if !last_added_option.is_ready:
			yield(last_added_option, "ready")
	
	emit_signal("option_update_finished")


func clear_options():
	for column in column_container.get_children():
		for option in column.get_children():
			option.queue_free()


func get_option_relative_line(option_id: int) -> int:
	var current_option_line = int(float(option_id) / max_columns)
	return current_option_line - current_top_line


func must_option_be_displayed(option_id: int) -> bool:
	var current_option_line = int(float(option_id) / max_columns)
	return current_option_line >= current_top_line && \
		current_option_line < current_top_line + max_lines


func find_option(opt_text: String) -> Button:
	for column in column_container.get_children():
		for option in column.get_children():
			if option.get_text().capitalize() == opt_text.capitalize():
				return option
	return null


func find_sub_menu(menu_name: String) -> Node:
	return menu_root.find_node(menu_name, true, false)


func scroll_down():
	var nb_options = current_menu.get_child_count()
	var total_nb_lines = int(round(nb_options / max_columns))
	var next_top_line = int(clamp(current_top_line + 1, 0, total_nb_lines - max_lines))
	
	if next_top_line != current_top_line:
		current_top_line = next_top_line
		var result = update_options()
		
		if result is GDScriptFunctionState:
			result = yield(self, "option_update_finished")
			
		scroll_focus(1)


func scroll_up():
	var next_top_line = current_top_line - 1
	if next_top_line < 0:
		next_top_line = 0
	
	if next_top_line != current_top_line:
		current_top_line = next_top_line
		var result = update_options()
		
		if result is GDScriptFunctionState:
			result = yield(self, "option_update_finished")
		
		scroll_focus(-1)


func scroll_focus(scroll_amount: int) -> void:
	var focused_option = get_focused_option()
	var focused_option_id = focused_option.get_index()
	var column = focused_option.get_parent()
	
	var next_option_focused_id = focused_option_id + scroll_amount
	if next_option_focused_id < 0 or next_option_focused_id > column.get_child_count() - 1:
		return
	
	var next_focused_option = column.get_child(next_option_focused_id)
	next_focused_option.grab_focus()


func get_focused_option() -> Button:
	return column_container.get_focus_owner()


func are_all_columns_empty() -> bool:
	for column in column_container.get_children():
		if column.get_child_count() > 0:
			return false
	return true

# Change this name?
func navigate_upstream_menu():
	if current_menu == menu_root:
		return
	
	var next_menu = current_menu.get_parent()
	current_menu.clear()
	
	set_current_menu(next_menu)


#### INPUTS ####

func _input(_event: InputEvent) -> void:
	
	if Input.is_action_just_pressed("ui_cancel"):
		if current_menu != menu_root:
			get_tree().set_input_as_handled()
			navigate_upstream_menu()
			return
	
	var focused_option = get_focus_owner()
	if focused_option == null:
		return
	
	var focused_option_line = focused_option.get_index() 
	
	if Input.is_action_just_pressed("ui_down"):
		var column = focused_option.get_parent()
		if focused_option_line >= column.get_child_count() - 1:
			scroll_down()
	
	elif Input.is_action_just_pressed("ui_up"):
		if focused_option_line == 0:
			scroll_up()


#### SIGNAL RESPONSES ####

func _on_option_table_size_changed():
	update_whole_display()

func _on_menu_changed():
	pass
