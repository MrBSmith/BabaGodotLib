extends RigidBody2D

var texture : Texture2D = null
var sprite_region_rect := Rect2()
var shape : Shape2D = null

func _ready() -> void:
	if texture: $Sprite2D.set_texture(texture)
	if shape: $CollisionShape2D.set_shape(shape)
	
	if sprite_region_rect != Rect2():
		$Sprite2D.set_region_rect(sprite_region_rect)
		$Sprite2D.region_enabled = true


func _process(_delta: float) -> void:
	modulate.a = lerp(modulate.a, 0.0, 0.05)
	if modulate.a < 0.05:
		queue_free()
