extends RigidBody2D


func _process(_delta: float) -> void:
	modulate.a = lerp(modulate.a, 0.0, 0.05)
	if modulate.a < 0.05:
		queue_free()
