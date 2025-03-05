extends RigidBody2D
class_name Debris

const FADE_DURATION = 1.5

var texture : Texture = null
var sprite_region_rect := Rect2()
var shape : Shape2D = null
var disabled := false setget set_disabled

signal debris_disappeared
signal disabled_changed


func set_disabled(value: bool) -> void:
	if value != disabled:
		disabled = value
		emit_signal("disabled_changed")


func _ready() -> void:
	_on_disabled_changed()


func _on_tween_finished() -> void:
	set_disabled(true)
	emit_signal("debris_disappeared")


func _on_disabled_changed() -> void:
	modulate.a = 0.0 if disabled else 1.0
	set_process(!disabled)
	set_visible(!disabled)
	set_sleeping(disabled)
	
	if is_inside_tree() and !disabled:
		if texture: $Sprite.set_texture(texture)
		if shape: $CollisionShape2D.set_shape(shape)
		
		if sprite_region_rect != Rect2():
			$Sprite.set_region_rect(sprite_region_rect)
			$Sprite.region_enabled = true
	
		var tween = create_tween()
		var __ = tween.tween_property(self, "modulate:a", 0.0, FADE_DURATION)
		__ = tween.connect("finished", self, "_on_tween_finished")

