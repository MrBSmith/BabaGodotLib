extends Factory
class_name VFX_Factory

### ADD A ALGO THAT REPLACE THE PATH OF EACH VFX SCENE BY ITS CORRESPONDING LOADED PACKED SCENE ###
export var vfx_dict : Dictionary = {}

#### ACCESSORS ####

func is_class(value: String): return value == "VFX_Factory" or .is_class(value)
func get_class() -> String: return "VFX_Factory"


#### BUILT-IN ####

func _ready() -> void:
	var _err = EVENTS.connect("play_VFX", self, "play_VFX")
	_err = EVENTS.connect("play_VFX_scene", self, "play_VFX_scene")

#### VIRTUALS ####



#### LOGIC ####

func play_VFX(fx_name: String, pos: Vector2, state_dict : Dictionary = {}) -> void:
	if not fx_name in vfx_dict.keys():
		print("The fx named " + fx_name + " doesn't exist in the dictionnary")
		return
	
	var scene = vfx_dict[fx_name]
	play_VFX_scene(scene, pos, state_dict)


func play_VFX_scene(scene: PackedScene, pos: Vector2, state_dict : Dictionary = {}) -> void:
	var fx_node = scene.instance()
	fx_node.set_global_position(pos)
	
	for key in state_dict.keys():
		var setter_name = "set_" + key
		if fx_node.has_method(setter_name):
			fx_node.call(setter_name, state_dict[key])
		else:
			fx_node.set(key, state_dict[key])
	
	owner.add_child(fx_node)



#### INPUTS ####



#### SIGNAL RESPONSES ####
