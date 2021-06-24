extends RenderPart
class_name IsoRenderPart


#### ACCESSORS ####

func is_class(value: String): return value == "IsoRenderPart" or .is_class(value)
func get_class() -> String: return "IsoRenderPart"


#### BUILT-IN ####

func _init(obj: Node, sprite_array: Array, cell: Vector3, world_pos: Vector2,
		alt: int = 0, mod:= Color.white) -> void:
	
	set_current_cell(cell)
	set_object_ref(obj)
	set_modulate(mod)
	set_global_position(world_pos)
	set_altitude(alt)
	
	for sprite in sprite_array:
		var sprite_node = Sprite.new()
		
		if sprite is IsoAnimatedSprite:
			var _err = sprite.connect("texture_changed", self, "_on_animated_sprite_texture_changed")
		elif sprite is IsoSprite:
			var _err = sprite.connect("sprite_texture_changed", self, "_on_sprite_texture_changed")
		
		var _err = sprite.connect("flip_changed", self, "_on_sprite_flip_changed")
		_err = sprite.connect("hidden_changed", self, "_on_sprite_hidden_changed")
		
		add_child(sprite_node, true)
		sprite_node.set_name(sprite.name)
		sprite_node.set_owner(self)
		sprite_node.set_visible(!sprite.is_hidden())
		var part_texture = AtlasTexture.new()
		sprite_node.set_texture(part_texture)
		
		apply_texture_change(sprite, sprite_node)


func _ready() -> void:
	var _err = object_ref.connect("cell_changed", self, "_on_object_cell_changed")
	_err = object_ref.connect("global_position_changed", self, "_on_object_global_position_changed")
	_err = object_ref.connect("modulate_changed", self, "_on_object_modulate_changed")
	_err = connect("cell_changed", renderer, "_on_part_cell_changed")


#### VIRTUALS ####



#### LOGIC ####

func apply_texture_change(obj_sprite: Node2D, sprite_node: Sprite) -> void:
	var texture = null
	
	if obj_sprite is IsoAnimatedSprite:
		var animation = obj_sprite.get_animation()
		var current_frame = obj_sprite.get_frame()
		var sprite_frames = obj_sprite.get_sprite_frames()
		var frame_texture = sprite_frames.get_frame(animation, current_frame)
		if frame_texture != null:
			texture = frame_texture.duplicate()
	else:
		texture = obj_sprite.get_texture().duplicate()
	
	var height = get_object_ref().get_height()
	var texture_size = texture.get_size() if texture != null else Vector2.ZERO
	var is_region_enabled = obj_sprite.is_region() if obj_sprite is Sprite else false
	
	var region_rect = obj_sprite.get_region_rect() if is_region_enabled else Rect2(Vector2.ZERO, texture_size)
	
	var sprite_centered = obj_sprite.is_centered()
	var sprite_pos = obj_sprite.get_position()
	var sprite_offset = obj_sprite.get_offset()
	
	var sprite_modul = obj_sprite.get_modulate()
	
	var part_size = Vector2(region_rect.size.x, region_rect.size.y / height) if height > 1 else region_rect.size
	
	var part_i = height - altitude
	
	if texture is AtlasTexture:
		texture.set_region(Rect2(texture.get_region().position + Vector2(0, part_size.y * part_i), part_size))
	else:
		sprite_node.set_region_rect(Rect2(region_rect.position + Vector2(0, part_size.y * part_i), part_size))
	
	var height_offset = Vector2(0, -part_size.y * (altitude  - 1)) if height > 1 else Vector2.ZERO
	var centered_offset = (Vector2(0, part_size.y) / 2) * int(sprite_centered && height > 1)
	var offset = sprite_pos + sprite_offset + height_offset + centered_offset
	
	if not obj_sprite is IsoAnimatedSprite:
		sprite_node.set_region(is_region_enabled or height > 1)
	
	sprite_node.set_texture(texture)
	sprite_node.set_modulate(sprite_modul)
	sprite_node.set_offset(offset)


#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_object_cell_changed(cell: Vector3):
	set_current_cell(cell + Vector3(0, 0, get_altitude()))


func _on_object_global_position_changed(world_pos: Vector2):
	set_global_position(world_pos)


func _on_object_modulate_changed(mod: Color):
	set_modulate(mod)


func _on_sprite_flip_changed(obj_sprite, flip_h: bool, flip_v: bool):
	var sprite_node = get_node(obj_sprite.name)
	sprite_node.set_flip_h(flip_h)
	sprite_node.set_flip_v(flip_v)


func _on_animated_sprite_texture_changed(obj_sprite: IsoAnimatedSprite):
	var sprite_node = get_node(obj_sprite.name)
	apply_texture_change(obj_sprite, sprite_node)


func _on_sprite_texture_changed(sprite: IsoSprite):
	var sprite_node = get_node(sprite.name)
	sprite_node.set_texture(sprite.get_texture())
	sprite_node.set_region_rect(sprite.get_region_rect())
	sprite_node.set_offset(sprite.get_offset())


func _on_sprite_hidden_changed(sprite: Node2D, value: bool):
	var sprite_node = get_node(sprite.name)
	sprite_node.set_visible(!value)
