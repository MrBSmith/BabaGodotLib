extends RenderPart
class_name TileRenderPart

var visibility : int = IsoObject.VISIBILITY.VISIBLE setget set_visibility, get_visibility
var outline_shader_material = "" 


#### ACCESSORS ####

func is_class(value: String): return value == "TileRenderPart" or .is_class(value)
func get_class() -> String: return "TileRenderPart"

func set_visibility(value: int):
	if value != visibility:
		visibility = value
		set_modulate(IsoObject.COLOR_SCHEME[visibility])

func get_visibility() -> int: return visibility

#### BUILT-IN ####

func _init(obj: Node, tex: AtlasTexture, cell: Vector3, world_pos: Vector2, alt: int = 0,
		offset := Vector2.ZERO, mod:= Color.white) -> void:
	
	set_current_cell(cell)
	set_object_ref(obj)
	set_modulate(mod)
	set_global_position(world_pos)
	set_altitude(alt)

	set_texture(tex)
	set_offset(offset)


#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####
