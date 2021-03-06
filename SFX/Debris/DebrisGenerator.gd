extends Node


### ADD A ALGO THAT REPLACE THE PATH OF EACH SFX SCENE BY ITS CORRESPONDING LOADED PACKED SCENE ###
export var sfx_dict : Dictionary = {}

onready var debris = preload("res://BabaGodotLib/SFX/Debris/Debris.tscn")


#### BUILT-IN ####

func _ready() -> void:
	var _err = EVENTS.connect("play_SFX", self, "_on_play_SFX")
	_err = EVENTS.connect("scatter_object", self, "_on_scatter_object")



#### SIGNAL_RESPONSES ####

func _on_scatter_object(body : Node, nb_debris : int, impulse_force: float = 100.0):
	var body_owner = body.get_owner()
	var sprite = body.get_node("Sprite")
	var texture = sprite.get_texture()
	var is_region = sprite.is_region()
	var texture_origin = sprite.get_region_rect().position if is_region else Vector2.ZERO
	
	var sprite_width : float = texture.get_width() if !is_region else sprite.get_region_rect().size.x
	var sprite_height : float = texture.get_height() if !is_region else sprite.get_region_rect().size.y
	
	var body_global_pos : Vector2 = body.get_global_position()
	var body_origin : Vector2 = body_global_pos
	body_origin.x = body_origin.x - (sprite_width / 2)
	body_origin.y = body_origin.y - (sprite_height / 2)
	
	var square_size = int(sqrt((sprite_width * sprite_height) / nb_debris))
	
	var row_len = int(sprite_width / square_size)
	var col_len = int(sprite_height / square_size)
	
	for i in range(row_len):
		for j in range(col_len):
			var debris_node = debris.instance()
			var debris_sprite = debris_node.get_node("Sprite")
			var collision_shape = RectangleShape2D.new()
			collision_shape.set_extents((Vector2.ONE * square_size) / 2)
			
			debris_node.get_node("CollisionShape2D").set_shape(collision_shape)
			
			var global_pos = Vector2(body_origin.x + i * square_size, body_origin.y + j * square_size)
			debris_node.set_global_position(global_pos)
			
			debris_sprite.set_texture(texture)
			debris_sprite.set_region(true)
			debris_sprite.set_region_rect(Rect2(texture_origin + Vector2(i, j) * square_size, 
												Vector2.ONE * square_size))
			
			var epicenter_dir = global_pos.direction_to(body_global_pos)
			debris_node.apply_central_impulse(-(epicenter_dir * impulse_force * rand_range(0.7, 1.3)))
			debris_node.apply_central_impulse(-(epicenter_dir * impulse_force * rand_range(0.7, 1.3)))
			
			if body_owner != null:
				body_owner.call_deferred("add_child", debris_node)
			else:
				call_deferred("add_child", debris_node)


func _on_play_SFX(fx_name: String, pos: Vector2):
	if not fx_name in sfx_dict.keys():
		print("The fx named " + fx_name + " doesn't exist in the dictionnary")
		return
	
	var fx = load(sfx_dict[fx_name])
	var fx_node = fx.instance()
	fx_node.set_global_position(pos)
	add_child(fx_node)
	fx_node.play_animation()
