tool
extends NinePatchRect
class_name DescriptionWindow

const text_line_container_scene = preload("res://BabaGodotLib/UI/LineContainer/TextLineContainer.tscn")

onready var tween = $Tween
onready var lines_container = $VBoxContainer

export var content_margin := Vector2(6.0, 6.0)

var is_ready : bool = false

#### ACCESSORS ####

func is_class(value: String): return value == "DescriptionWindow" or .is_class(value)
func get_class() -> String: return "DescriptionWindow"


#### BUILT-IN ####

func _ready() -> void:
	var __ = connect("resized", self, "_on_window_resized")
	lines_container.set_position(content_margin)
	
	is_ready = true


#### VIRTUALS ####



#### LOGIC ####

func feed(data_array: Array):
	for line in data_array:
		if not line is LineData:
			print("The dialogue window  " + get_path() + " was feed with an incorect obecjt type")
			print("The type is "  + line.get_class() + " where it should be a LineDataContainer")
			continue
		
		add_line(line)


func add_line(line_data: LineData, line_id: int = -1):
	if !is_ready:
		yield(self, "ready")
	
	var line = null
	
	match(line_data.get_class()):
		"NormalLineData" : line = instanciate_normal_line(line_data)
		"IconsLineData" : line = instanciate_icon_line(line_data)
	
	lines_container.add_child(line)
	line.set_hidden(false)
	line.set_owner(self)
	
	if line_id >= 0:
		if !line.is_inside_tree():
			yield(line, "tree_entered")
		lines_container.move_child(line, line_id)


func instanciate_normal_line(line_data: NormalLineData) -> TextLineContainer:
	var line : TextLineContainer = text_line_container_scene.instance()
	
	line.set_text(line_data.text)
	line.set_icon_texture(line_data.texture)
	line.set_amount(line_data.amount)
	
	return line


func instanciate_icon_line(_line_data: LineData):
	pass


func update_line_container_size():
	lines_container.set_size(get_size() - content_margin * 2) 


#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_window_resized():
	update_line_container_size()
