extends UIAnimationModule
class_name FadeAnimationModule

enum FADE_MODE {
	CONTENT,
	CONTAINER,
	CONTENT_THEN_CONTAINER,
	CONTAINER_THEN_CONTENT,
	BOTH
}

export(FADE_MODE) var fade_mode : int = FADE_MODE.CONTENT
export var visible : bool = true

signal content_fade_finished
signal container_fade_finished

#### ACCESSORS ####

func is_class(value: String): return value == "FadeAnimationModule" or .is_class(value)
func get_class() -> String: return "FadeAnimationModule"


#### BUILT-IN ####



#### VIRTUALS ####

func play() -> void:
	match(fade_mode):
		FADE_MODE.CONTENT:
			_fade_content()
			yield(self, "content_fade_finished")
		
		FADE_MODE.CONTAINER:
			_fade_container()
			yield(self, "container_fade_finished")
		
		FADE_MODE.CONTENT_THEN_CONTAINER:
			_fade_content()
			yield(self, "content_fade_finished")
			
			_fade_container()
			yield(self, "container_fade_finished")
		
		FADE_MODE.CONTAINER_THEN_CONTENT, FADE_MODE.BOTH:
			_fade_container()
			if fade_mode == FADE_MODE.CONTAINER_THEN_CONTENT:
				yield(self, "container_fade_finished")
			
			_fade_content()
			yield(self, "content_fade_finished")
	
	visible = !visible
	emit_signal("animation_finished")



#### LOGIC ####

func _set_children_visible(value: bool) -> void:
	for child in target.get_children():
		if not child is Control:
			continue
		
		child.set_visible(value)


# Content fade in/out animation
func _fade_content() -> void:
	var dur = anim_duration / 2.0 if fade_mode in [FADE_MODE.CONTAINER_THEN_CONTENT, FADE_MODE.CONTENT_THEN_CONTAINER] else anim_duration 
	var tween = create_tween()
	
	var trans_type = trans_type_in if !visible else trans_type_out
	var ease_type = ease_type_in if !visible else ease_type_out
	
	tween.set_trans(trans_type)
	tween.set_ease(ease_type)
	
	for child in target.get_children():
		if child is Control:
			var to_mod = Color.white if !visible else Color.transparent
			
			var __ = tween.tween_property(child, "modulate", to_mod, dur)
	
	yield(tween, "finished")
	emit_signal("content_fade_finished")


func _fade_container() -> void:
	var to_mod = Color.white if !visible else Color.transparent
	var dur = anim_duration / 2.0 if fade_mode in [FADE_MODE.CONTAINER_THEN_CONTENT, FADE_MODE.CONTENT_THEN_CONTAINER] else anim_duration 
	var tween = create_tween()
	
	var trans_type = trans_type_in if visible else trans_type_out
	var ease_type = ease_type_in if visible else ease_type_out
	
	tween.set_trans(trans_type)
	tween.set_ease(ease_type)
	
	var __ = tween.tween_property(target, "modulate", to_mod, dur)
	
	yield(tween, "finished")
	emit_signal("container_fade_finished")




#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_target_changed() -> void:
	var mod = Color.transparent if !visible else Color.white
	
	for child in target.get_children():
		if child is Control:
			child.set_modulate(mod)
