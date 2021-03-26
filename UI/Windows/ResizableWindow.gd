tool
extends NinePatchRect
class_name ResizableWindow

export var resize_duration : float = 0.5

var tween_node : Tween = null
var is_resizing : bool = false

signal resize_animation_finished

#### ACCESSORS ####

func is_class(value: String): return value == "ResizableWindow" or .is_class(value)
func get_class() -> String: return "ResizableWindow"


#### BUILT-IN ####

func _ready() -> void:
	if owner:
		yield(owner, "ready")
	
	tween_node = Tween.new()
	add_child(tween_node)
	
	yield(tween_node, "ready")
	tween_node.set_owner(self)

#### VIRTUALS ####



#### LOGIC ####

func trigger_resize_animation(target_size: Vector2, grow_dir: int, 
		trans_type := Tween.TRANS_BOUNCE, ease_type := Tween.EASE_OUT):
	
	if target_size == rect_size or tween_node == null:
		emit_signal("resize_animation_finished")
		return
	
	var size_difference : Vector2 = target_size - get_size()
	
	var margin_to_interpol = []
	
	if grow_dir < 2: margin_to_interpol.append("margin_bottom")
	else: margin_to_interpol.append("margin_top")
	
	if grow_dir % 2 == 0: margin_to_interpol.append("margin_left")
	else: margin_to_interpol.append("margin_right")
	
	for margin_name in margin_to_interpol:
		var final_value : float = INF
		
		match(margin_name):
			"margin_left": final_value = get(margin_name) -size_difference.x
			"margin_top": final_value = get(margin_name) -size_difference.y
			"margin_right": final_value = get(margin_name) + size_difference.x
			"margin_bottom": final_value = get(margin_name) + size_difference.y 
		
		var __ = tween_node.interpolate_property(self, margin_name, get(margin_name), 
						final_value, resize_duration, trans_type, ease_type)
	
	is_resizing = true
	var __ = tween_node.start()
	
	yield(tween_node, "tween_all_completed")
	is_resizing = false
	emit_signal("resize_animation_finished")


func get_top_left_corner() -> Vector2:
	return Vector2(get_margin(MARGIN_LEFT), get_margin(MARGIN_TOP))

#### INPUTS ####



#### SIGNAL RESPONSES ####

