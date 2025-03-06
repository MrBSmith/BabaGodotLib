extends RigidBody2D
class_name Debris

const FADE_DURATION = 1.5

var texture : Texture = null
var sprite_region_rect := Rect2()
var shape : Shape2D = null
var disabled := false setget set_disabled
var buffered_position = Vector2.ZERO

onready var col_mask = collision_mask
onready var col_layer = collision_layer

signal debris_disappeared
signal disabled_changed


func set_disabled(value: bool) -> void:
	if value != disabled:
		disabled = value
		emit_signal("disabled_changed")


func _ready() -> void:
	var __ = connect("disabled_changed", self, "_on_disabled_changed")
	_on_disabled_changed()


func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	if buffered_position != Vector2.ZERO:
		state.sleeping = false
		state.linear_velocity = Vector2.ZERO
		state.transform = Transform2D(0.0, buffered_position)
		buffered_position = Vector2.ZERO
		yield(get_tree(), "physics_frame")
		yield(get_tree(), "physics_frame")
		
		set_disabled(false)


func _on_tween_finished() -> void:
	set_disabled(true)
	emit_signal("debris_disappeared")


func _on_disabled_changed() -> void:
	modulate.a = 0.0 if disabled else 1.0
	set_process(!disabled)
	set_visible(!disabled)
	call_deferred("set_sleeping", disabled)
	collision_mask = 0 if disabled else col_mask
	collision_layer = 0 if disabled else col_layer
	
	if disabled:
		linear_velocity = Vector2.ZERO
		applied_force = Vector2.ZERO
	
	if is_inside_tree() and !disabled:
		if texture: $Sprite.set_texture(texture)
		if shape: $CollisionShape2D.set_shape(shape)
		
		if sprite_region_rect != Rect2():
			$Sprite.set_region_rect(sprite_region_rect)
			$Sprite.region_enabled = true
	
		var tween = create_tween()
		var __ = tween.tween_property(self, "modulate:a", 0.0, FADE_DURATION)
		__ = tween.connect("finished", self, "_on_tween_finished")

