extends MenuBase
class_name ListMenu

const menu_option_scene = preload("res://BabaGodotLib/UI/Menu/MenuOptionBase.tscn")

onready var column_container = $NinePatchRect/HBoxContainer

export var max_lines : int = 3
export var max_columns : int = 2

var current_top_line : int = 1

signal option_update_finished()

var data = [
	"option 1", "option 2", "option 3", "option 4", "option 5", 
	"option 6", "option 7", "option 8", "option 9", "option 10"
]

#### ACCESSORS ####

func is_class(value: String): return value == "ListMenu" or .is_class(value)
func get_class() -> String: return "ListMenu"


#### BUILT-IN ####

func _ready() -> void:
	create_columns()

#### VIRTUALS ####



#### LOGIC ####


func _setup():
	yield(self, "ready")
	update_options(data)
	for column in column_container.get_children():
		connect_menu_options(column, false)


func create_columns():
	for _i in range(max_columns):
		var column = VBoxContainer.new()
		column_container.add_child(column)


func feed_option_data(_data_array: Array):
	pass


func update_options(data_array: Array):
	var last_added_option : MenuOptionsBase = null
	for i in data_array.size():
		var column_id = i % max_columns
		
		var obj_name = data_array[i]
		var column = column_container.get_child(column_id)
		
		var option_already_displayed = find_column_option(column, obj_name)
		
		if must_option_be_displayed(i):
			if option_already_displayed == null:
				var option = menu_option_scene.instance()
				option.set_text(obj_name)
				
				column.add_child(option)
				last_added_option = option
				
				var line = get_option_relative_line(i)
				if line != max_lines - 1:
					column.move_child(option, line)
		else:
			if option_already_displayed != null:
				option_already_displayed.queue_free()
				yield(option_already_displayed, "tree_exited")
	
	if last_added_option != null:
		if !last_added_option.is_ready:
			yield(last_added_option, "ready")
	
	emit_signal("option_update_finished")


func get_option_relative_line(option_id: int) -> int:
	var current_option_line = int(float(option_id) / max_columns)
	return current_option_line - current_top_line


func must_option_be_displayed(option_id: int) -> bool:
	var current_option_line = int(float(option_id) / max_columns)
	return current_option_line >= current_top_line && \
		current_option_line < current_top_line + max_lines


func find_column_option(column: VBoxContainer, opt_text: String) -> Button:
	for option in column.get_children():
		if option.get_text() == opt_text:
			return option
	return null


func scroll_down():
	var nb_options = data.size()
	var total_nb_lines = int(round(nb_options / max_columns))
	var next_top_line = int(clamp(current_top_line + 1, 0, total_nb_lines - max_lines))
	
	if next_top_line != current_top_line:
		current_top_line = next_top_line
		var result = update_options(data)
		
		if result is GDScriptFunctionState:
			result = yield(self, "option_update_finished")
		scroll_focus(1)


func scroll_up():
	var next_top_line = current_top_line - 1
	if next_top_line < 0:
		next_top_line = 0
	
	if next_top_line != current_top_line:
		current_top_line = next_top_line
		var result = update_options(data)
		
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


#### INPUTS ####

func _input(_event: InputEvent) -> void:
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
