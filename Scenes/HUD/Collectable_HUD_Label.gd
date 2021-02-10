extends Control
class_name Collectable_HUD_Label

export var maximum_amount : int = 0
export var collectable_type : String = ""
onready var label = $Label

#### ACCESSORS ####

func is_class(value: String): return value == "Collectable_HUD_Label" or .is_class(value)
func get_class() -> String: return "Collectable_HUD_Label"


#### BUILT-IN ####

func _ready() -> void:
	var __ = Events.connect("collect", self, "_on_collect_obj_event")
	__ = Events.connect("collectable_collected", self, "_on_collectable_collected")

#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_collect_obj_event(obj: Node):
	if !obj.is_class(collectable_type):
		return
	
	var obj_duplicate = obj.duplicate()
	var obj_pos = obj.get_global_transform_with_canvas().origin
	obj_duplicate.connect("collect_animation_finished", self, "_on_obj_collect_animation_finished")
	call_deferred("add_child", obj_duplicate)
	
	obj_duplicate.set_position(obj_pos)
	obj_duplicate.trigger_collect_animation($Texture.get_position() + $Texture.get_rect().size / 2)
	
	obj.queue_free()


func _on_obj_collect_animation_finished():
	var tween = $Tween
	var texture = $Texture
	var base_scale = texture.get_scale()
	
	tween.interpolate_property(texture, "scale",
		base_scale, base_scale * 1.4, 0.15, 
		Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT)
	
	tween.start()
	
	yield(tween, "tween_all_completed")
	
	tween.interpolate_property(texture, "scale",
		texture.get_scale(), base_scale, 0.2, 
		Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT)
	
	tween.start()


func _on_collectable_collected(obj: Collectable, amount: int):
	if !obj.is_class(collectable_type):
		return
	
	label.set_text(String(amount))
	if maximum_amount != 0:
		label.set_text(label.get_text() + "/" + String(owner.gold_objective))
