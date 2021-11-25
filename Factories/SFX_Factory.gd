extends Factory
class_name SFX_Factory

### ADD A ALGO THAT REPLACE THE PATH OF EACH SFX SCENE BY ITS CORRESPONDING LOADED PACKED SCENE ###
export var sfx_dict : Dictionary = {}

#### ACCESSORS ####

func is_class(value: String): return value == "SFX_Factory" or .is_class(value)
func get_class() -> String: return "SFX_Factory"


#### BUILT-IN ####

func _ready() -> void:
	var _err = EVENTS.connect("play_SFX", self, "_on_play_SFX")

#### VIRTUALS ####



#### LOGIC ####

func play_SFX(fx_name: String, pos: Vector2) -> void:
	if not fx_name in sfx_dict.keys():
		print("The fx named " + fx_name + " doesn't exist in the dictionnary")
		return
	
	var fx = load(sfx_dict[fx_name])
	var fx_node = fx.instance()
	fx_node.set_global_position(pos)
	add_child(fx_node)
	fx_node.play_animation()

#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_play_SFX(fx_name: String, pos: Vector2) -> void:
	play_SFX(fx_name, pos)
