extends Object
class_name Math

#### INTEGERS ####

static func is_even(value: int) -> bool:
	return value % 2 == 0

static func randi_range(min_value: int, max_value: int) -> int:
	return randi() % ((max_value - min_value) + 1) + min_value

static func bool_to_sign(value: bool) -> int:
	return int(value) * 2 - 1

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

static func clamp_v(val: Vector2, min_val: Vector2, max_val: Vector2) -> Vector2:
	 return Vector2(clamp(val.x, min_val.x, max_val.x),
					clamp(val.y, min_val.y, max_val.y))

# Compare the two given vec2's angle and check if their difference is lesser than max_angle_diff
static func compare_dir(dir1: Vector2, dir2: Vector2, max_angle_diff: float) -> bool:
	if dir1 in [Vector2.ZERO, Vector2.INF] or dir2 in [Vector2.ZERO, Vector2.INF]:
		return false
	
	return abs(dir1.angle() - dir2.angle()) <= max_angle_diff

#### GEOMETRY ####

# Returns in radians the angle of the summit a in relation with b and c
static func compute_3_points_angle(a: Vector2, b: Vector2, c: Vector2) -> float:
	return acos(pow(a.distance_to(b), 2) + pow(a.distance_to(c), 2) - pow(b.distance_to(c), 2)) / (2 * a.distance_to(b) * a.distance_to(c))


static func compute_triangle_surface(tri: PoolVector2Array) -> float:
	if tri.size() != 3:
		push_error("The given PoolVector2Array must contains exactly 3 vertices, current contains %d" % tri.size())
		return 0.0
	
	var a = tri[0].distance_to(tri[1])
	var b = tri[0].distance_to(tri[2])
	var c_angle = compute_3_points_angle(tri[0], tri[1], tri[2])
	
	return ((a * b) / 2) * sin(c_angle)


static func compute_polygon_surface(polygon: PoolVector2Array) -> float:
	var sum : float = 0.0
	for i in range(polygon.size()):
		var point = polygon[i]
		var next_i = wrapi(i + 1, 0, polygon.size())
		sum += (point.x + polygon[next_i].x) * (polygon[next_i].y - point.y)
	
	return sum


static func rect_shape_to_polygon(rect_shape: RectangleShape2D, trans: Transform2D) -> PoolVector2Array:
	var local_coords = PoolVector2Array(
		[
			-rect_shape.extents,
			Vector2(rect_shape.extents.x, -rect_shape.extents.y),
			rect_shape.extents,
			Vector2(-rect_shape.extents.x, rect_shape.extents.y)
		]
	)

	return trans.xform(local_coords)


