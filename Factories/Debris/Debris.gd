extends RigidBody2D


func _process(_delta: float) -> void:
	modulate.a = lerp(modulate.a, 0.0, 0.05)
	if is_equal_approx(modulate.a, 0.0):
		queue_free()
