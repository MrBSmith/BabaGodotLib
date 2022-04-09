extends Factory
class_name VFX_Factory

### ADD A ALGO THAT REPLACE THE PATH OF EACH VFX SCENE BY ITS CORRESPONDING LOADED PACKED SCENE ###
export var vfx_dict : Dictionary = {}

#### ACCESSORS ####

func is_class(value: String): return value == "VFX_Factory" or .is_class(value)
func get_class() -> String: return "VFX_Factory"


#### BUILT-IN ####

func _ready() -> void:
	var _err = EVENTS.connect("play_VFX", self, "_on_play_VFX")

#### VIRTUALS ####



#### LOGIC ####

func play_VFX(fx_name: String, pos: Vector2, state_dict : Dictionary = {}) -> void:
	if not fx_name in vfx_dict.keys():
		print("The fx named " + fx_name + " doesn't exist in the dictionnary")
		return
	
	var fx = vfx_dict[fx_name]
	var fx_node = fx.instance()
	fx_node.set_global_position(pos)
	
	for key in state_dict.keys():
		fx_node.set(key, state_dict[key])
	
	add_child(fx_node)
	fx_node.play_animation()



#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_play_VFX(fx_name: String, pos: Vector2, state_dict : Dictionary = {}) -> void:
	play_VFX(fx_name, pos, state_dict)
