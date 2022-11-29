extends Control
class_name SizeMimic

@export var target_path : NodePath : set = set_target_path
@onready var target : Control = get_node(target_path) as Control if !target_path.is_empty() else null : set = set_target

signal target_changed

#### ACCESSORS ####

func is_class(value: String): return value == "SizeMimic" or super.is_class(value)
func get_class() -> String: return "SizeMimic"

func set_target_path(value: NodePath) -> void:
	target_path = value
	var new_target : Control = get_node_or_null(target_path) as Control
	set_target(new_target)

func set_target(value: Control) -> void:
	if value != target:
		var previous_target = target
		target = value
		emit_signal("target_changed", previous_target, target)


#### BUILT-IN ####


func _init():
	var __ = connect("target_changed",Callable(self,"_on_target_changed"))



func _ready() -> void:
	_on_target_changed(null, target)



#### VIRTUALS ####



#### LOGIC ####

func _update_rect_size() -> void:
	if !size.is_equal_approx(target.size):
		size = target.size


#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_target_changed(previous_target: Control, new_target: Control) -> void:
	if previous_target:
		if !previous_target.is_connected("resized",Callable(self,"_on_target_resized")):
			previous_target.disconnect("resized",Callable(self,"_on_target_resized"))
	
	if new_target:
		if !new_target.is_connected("resized",Callable(self,"_on_target_resized")):
			var __ = new_target.connect("resized",Callable(self,"_on_target_resized"))


func _on_target_resized() -> void:
	_update_rect_size()
