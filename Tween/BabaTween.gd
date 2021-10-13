extends Tween
class_name BabaTween

signal appear_anim_finished(elem)

#### ACCESSORS ####

func is_class(value: String): return value == "BabaTween" or .is_class(value)
func get_class() -> String: return "BabaTween"


#### BUILT-IN ####



#### VIRTUALS ####



#### LOGIC ####

func appear(elem: CanvasItem, from := Color.transparent, to := Color.white, 
				dur: float = 1.0, delay: float = 0.0,  trans_type : int = Tween.TRANS_LINEAR, 
								ease_type: int =  Tween.EASE_IN_OUT) -> void:
	
	var __ = interpolate_property(elem, "modulate", from, to, dur, trans_type, ease_type, delay)
	__ = start()
	
	yield(self, "tween_all_completed")
	emit_signal("appear_anim_finished", elem)



#### INPUTS ####



#### SIGNAL RESPONSES ####
