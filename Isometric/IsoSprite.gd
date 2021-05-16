extends Sprite
class_name IsoSprite

# A base class for Sprite used to be rendered by the IsoRenderer
# These are NOT rendered direcly by the engine, but are copied, 
# scattered then rendered in the correct order by the IsoRenderer

# Make sure to use the property hidden if you want to change the 
# visiblity of the sprite beeing rendered by the IsoRenderer and not the visible property
# visible should basicly always be false in a context using the IsoRenderer

export var hidden : bool = false setget set_hidden, is_hidden

#warning-ignore:unused_signal
signal sprite_texture_changed(sprite)
signal flip_changed(flipH, flipV)
signal hidden_changed(sprite, value)

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

func set_hidden(value: bool):
	hidden = value
	emit_signal("hidden_changed", self, hidden)

func is_hidden() -> bool: return hidden


#### BUILT-IN ####



#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####
