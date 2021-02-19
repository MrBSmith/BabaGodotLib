extends Sprite
class_name IsoSprite

# A base class for Sprite used to be rendered by the IsoRenderer

#warning-ignore:unused_signal
signal sprite_texture_changed(sprite)
signal flip_changed(flipH, flipV)

#### ACCESSORS ####

func is_class(value: String): return value == "IsoSprite" or .is_class(value)
func get_class() -> String: return "IsoSprite"

func set_flip_h(value: bool):
	if value != flip_h:
		.set_flip_h(value)
		emit_signal("flip_changed", flip_h, flip_v)

func set_flip_v(value: bool):
	if value != flip_v:
		.set_flip_v(value)
		emit_signal("flip_changed", flip_h, flip_v)

#### BUILT-IN ####



#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####
