extends Control
class_name Collectable_HUD_Label

export var maximum_amount : int = 0
export var collectable_type : String = ""
onready var label = $Label
onready var base_texture_scale = $Texture.get_scale()


#### ACCESSORS ####

func is_class(value: String): return value == "Collectable_HUD_Label" or .is_class(value)
func get_class() -> String: return "Collectable_HUD_Label"


#### BUILT-IN ####

func _ready() -> void:
	var __ = EVENTS.connect("collect", self, "_on_collect_obj_event")
	__ = EVENTS.connect("collectable_amount_updated", self, "_on_collectable_amount_updated")

#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_collect_obj_event(obj: Collectable):
	if obj == null or obj.get_collectable_name() != collectable_type:
		return
	
	var obj_duplicate = obj.duplicate()
	var obj_pos = obj.get_global_transform_with_canvas().origin
	obj_duplicate.connect("collect_animation_finished", self, "_on_obj_collect_animation_finished")
	owner.call_deferred("add_child", obj_duplicate)
	
	obj_duplicate.set_position(obj_pos)
	obj_duplicate.trigger_collect_animation($Texture)
	
	obj.queue_free()


func _on_obj_collect_animation_finished():
	var tween = $Tween
	var texture = $Texture
	
	var scale_prop_name = "rect_scale" if texture is Control else "scale"
	
	tween.interpolate_property(texture, scale_prop_name,
		base_texture_scale, base_texture_scale * 1.4, 0.15, 
		Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT)
	
	tween.start()
	
	yield(tween, "tween_all_completed")
	
	tween.interpolate_property(texture, scale_prop_name,
		texture.get_scale(), base_texture_scale, 0.2, 
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	tween.start()


func _on_collectable_amount_updated(col_type: String, amount: int):
	if col_type != collectable_type:
		return
	
	label.set_text(String(amount))
	if maximum_amount != 0:
		label.set_text(label.get_text() + "/" + String(owner.gold_objective))
