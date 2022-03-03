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


# Convert an angle (in radians) to a direction represented as a Vector2
static func angle_to_v2(angle: float) -> Vector2:
	return Vector2(cos(angle), sin(angle))


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


static func vec2_to_vec3(vec2: Vector2, z: float) -> Vector3:
	return Vector3(vec2.x, vec2.y, z)


static func vec2_from_vec3(vec3: Vector3) -> Vector2:
	return Vector2(vec3.x, vec3.y)


static func find_most_top_left_v2(array: PoolVector2Array) -> Vector2:
	var top_left_v = Vector2.INF
	for v in array:
		if v.y < top_left_v.y or (v.y == top_left_v.y && v.x < top_left_v.x):
			top_left_v = v
	return top_left_v


static func find_most_bottom_right_v2(array: PoolVector2Array) -> Vector2:
	var bottom_right_v = -Vector2.INF
	for v in array:
		if -v.y > bottom_right_v.y or (v.y == bottom_right_v.y && v.x > bottom_right_v.x):
			bottom_right_v = v
	return bottom_right_v


# This method takes a polygon representing a rectangle and convert it to Rect2
# The polygon must have exactly 4 points, and the points must be 
# disposed as a rectangle or it will result as unexpected behaviours
static func poly2rect(polygon: PoolVector2Array) -> Rect2:
	if polygon.size() != 4:
		push_error("The given polygon doesn't have the right amount of points, it must have exactlty 4 points")
		return Rect2()
	
	var top_left = find_most_top_left_v2(polygon)
	var bottom_right = find_most_bottom_right_v2(polygon)
	
	return Rect2(top_left, bottom_right - top_left)


static func rect2poly(rect: Rect2) -> PoolVector2Array:
	return PoolVector2Array([
		rect.position,
		rect.position + rect.size * Vector2.RIGHT,
		rect.end,
		rect.position + rect.size * Vector2.DOWN
	])


static func circle2poly(radius: float) -> PoolVector2Array:
	var points_array = PoolVector2Array()
	for i in range(20):
		var angle = deg2rad((360 / 20) * i)
		var point = angle_to_v2(angle) * radius
		points_array.append(point)
	
	return points_array


static func shape_to_poly(shape: Shape2D, global_transform: Transform) -> PoolVector2Array:
	if shape is RectangleShape2D:
		var rect = Rect2(Vector2.ZERO, shape.get_extents() * 2)
		return global_transform.xform(rect2poly(rect))
	
	elif shape is CircleShape2D:
		return global_transform.xform(circle2poly(shape.radius))
	
	if shape is ConvexPolygonShape2D:
		return global_transform.xform(shape.get_points())
	
	if shape is ConcavePolygonShape2D:
		return global_transform.xform(shape.get_segments())
	
	if shape is CapsuleShape2D:
		return PoolVector2Array()
	
	return PoolVector2Array()


# Sums the distance between each points of the line to get its total lenght
# If to_id is -1 compute the line's total length
# If to_id is a valid id, compute the line's length from line[0] to line[to_id]
static func compute_line_length(line : PoolVector2Array, to_id : int =  -1) -> float:
	var previous_point := Vector2.INF
	var total_dist : float = 0.0
	var max_id = line.size() if to_id == -1 else to_id + 1
	
	for i in range(max_id):
		var point = line[i]
		if previous_point != Vector2.INF:
			total_dist += previous_point.distance_to(point)
		
		previous_point = point
	return total_dist


static func find_line_nearest_point(point: Vector2, line: PoolVector2Array) -> Vector2:
	var nearest_point = Vector2.INF
	for line_point in line:
		if point.distance_to(line_point) < point.distance_to(nearest_point):
			nearest_point = line_point
	return nearest_point

