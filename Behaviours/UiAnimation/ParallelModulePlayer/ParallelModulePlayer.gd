extends Node
class_name ParallelModulePlayer

export var disabled : bool = false

signal animation_finished


#### ACCESSORS ####

func is_class(value: String): return value == "ParallelModulePlayer" or .is_class(value)
func get_class() -> String: return "ParallelModulePlayer"


#### BUILT-IN ####



#### VIRTUALS ####

func play() -> void:
	var longest_anim_module : UIAnimationModule = null
	
	for module in get_children():
		if not module is UIAnimationModule && !module.is_class("ParallelModulePlayer"):
			continue 
		
		module.play()
		
		if longest_anim_module == null or module.anim_duration > longest_anim_module.anim_duration:
			longest_anim_module = module
	
	var __ = longest_anim_module.connect("animation_finished", self, "_on_longest_anim_module_animation_finished", [], CONNECT_ONESHOT)


#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_longest_anim_module_animation_finished() -> void:
	emit_signal("animation_finished")
