extends AnimatedSprite
class_name IsoAnimatedSprite

signal texture_changed(sprite)

#### ACCESSORS ####

func is_class(value: String): return value == "IsoAnimatedSprite" or .is_class(value)
func get_class() -> String: return "IsoAnimatedSprite"


#### BUILT-IN ####

func _ready() -> void:
	var _err = connect("frame_changed", self, "_on_frame_changed")
	_err = connect("animation_finished", self, "_on_animation_finished")

#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_frame_changed():
	emit_signal("texture_changed", self)

func _on_animation_finished():
	emit_signal("texture_changed", self)
