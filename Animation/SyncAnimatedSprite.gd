extends AnimatedSprite
class_name SyncAnimatedSprite

signal animation_changed(anim)

#### ACCESSORS ####

func is_class(value: String): return value == "SyncAnimatedSprite" or .is_class(value)
func get_class() -> String: return "SyncAnimatedSprite"


#### BUILT-IN ####

func _ready() -> void:
	var parent = get_parent()
	if parent is AnimatedSprite:
		parent.connect("frame_changed", self, "_on_parent_frame_changed")
		
		if parent.is_class("SyncAnimatedSprite"):
			parent.connect("animation_changed", self, "_on_parent_animation_changed")


#### VIRTUALS ####



#### LOGIC ####

# FUNCTION OVERRIDE #
func play(anim: String = "", backwards: bool = false) -> void:
	if (anim == "" and get_animation() != "default") or anim != get_animation():
		emit_signal("animation_changed", anim, backwards)
	
	.play(anim, backwards)


#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_parent_frame_changed() -> void:
	set_frame(get_parent().get_frame())


func _on_parent_animation_changed(anim: String = "", backwards: bool = false) -> void:
	play(anim, backwards)
