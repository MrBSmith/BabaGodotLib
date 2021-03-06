extends Object
class_name Math

#### INTEGERS ####

static func is_even(value: int) -> bool:
	return value % 2 == 0

static func randi_range(min_value: int, max_value: int) -> int:
	return randi() % ((max_value - min_value) + 1) + min_value

static func rand_sign() -> int:
	return randi() % 2 * 2 - 1

static func clampi(initial_val: int, min_val: int, max_val: int) -> int:
	return int(clamp(float(initial_val), float(min_val), float(max_val)))


#### VECTOR2 ####

# Invert x and y members of the given Vector2
static func v2_invert_members(vec: Vector2) -> Vector2:
	return Vector2(vec.y, vec.x)

# Rotate the given Vector2 the given amount of degrees
static func v2_rotate_deg(vec: Vector2, rotation: float) -> Vector2:
	return vec.rotated(deg2rad(rotation) * PI)
