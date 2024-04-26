extends Factory
class_name DebrisFactory


export var max_debris_per_frame : int = 20

onready var debris = preload("res://BabaGodotLib/Factories/Debris/Debris.tscn")


#### BUILT-IN ####

func _ready() -> void:
	var _err = EVENTS.connect("scatter_object", self, "_on_scatter_object")



#### SIGNAL_RESPONSES ####

func _on_scatter_object(sprite : Sprite, nb_debris : int, impulse_force: float = 100.0, no_clip := false):
	var texture = sprite.get_texture()
	var is_region = sprite.is_region()
	var texture_origin = sprite.get_region_rect().position if is_region else Vector2.ZERO
	var z = sprite.get_z_index()
	var z_as_relative = sprite.is_z_relative()
	
	var sprite_width : float = texture.get_width() if !is_region else sprite.get_region_rect().size.x
	var sprite_height : float = texture.get_height() if !is_region else sprite.get_region_rect().size.y
	
	var body_global_pos : Vector2 = sprite.get_global_position()
	var body_origin : Vector2 = body_global_pos
	body_origin.x = body_origin.x - (sprite_width / 2)
	body_origin.y = body_origin.y - (sprite_height / 2)
	
	var square_size = int(sqrt((sprite_width * sprite_height) / nb_debris))
	
	var row_len = int(sprite_width / square_size)
	var col_len = int(sprite_height / square_size)
	var debris_counter : int = 0
	
	for i in range(row_len):
		for j in range(col_len):
			if debris_counter >= max_debris_per_frame:
				debris_counter = 0
			
			var debris_node = debris.instance()
			
			if !no_clip:
				var collision_shape = RectangleShape2D.new()
				collision_shape.set_extents((Vector2.ONE * square_size) / 2)
				debris_node.shape = collision_shape
			
			var global_pos = Vector2(body_origin.x + i * square_size, body_origin.y + j * square_size)
			debris_node.set_global_position(global_pos)
			
			debris_node.texture = texture
			debris_node.sprite_region_rect = Rect2(texture_origin + Vector2(i, j) * square_size, 
												Vector2.ONE * square_size)
			
			var epicenter_dir = global_pos.direction_to(body_global_pos)
			debris_node.apply_central_impulse(-(epicenter_dir * impulse_force * rand_range(0.7, 1.3)))
			
			debris_node.set_z_index(z)
			debris_node.set_z_as_relative(z_as_relative)
			target.call_deferred("add_child", debris_node)
			
			debris_counter += 1


