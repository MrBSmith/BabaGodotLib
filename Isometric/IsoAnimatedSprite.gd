extends AnimatedSprite
class_name IsoAnimatedSprite

# A base class for AnimatedSprite used to be rendered by the IsoRenderer

signal texture_changed(sprite)
signal flip_changed(flipH, flipV)

#### ACCESSORS ####

func is_class(value: String): return value == "IsoAnimatedSprite" or .is_class(value)
func get_class() -> String: return "IsoAnimatedSprite"

func set_flip_h(value: bool):
	if value != flip_h:
		.set_flip_h(value)
		emit_signal("flip_changed", flip_h, flip_v)

func set_flip_v(value: bool):
	if value != flip_v:
		.set_flip_v(value)
		emit_signal("flip_changed", flip_h, flip_v)


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
