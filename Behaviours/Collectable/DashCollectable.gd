extends FollowCollectable
class_name DashFollowCollectable

func is_class(value: String): return value == "DashFollowCollectable" or .is_class(value)
func get_class() -> String: return "DashFollowCollectable"


func _on_collect_area_body_entered(body: PhysicsBody2D) -> void:
	if body is Character and !body._has_dash_available():
		._on_collect_area_body_entered(body)

