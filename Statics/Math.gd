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
	var nb_points = 20
	for i in range(nb_points):
		var angle = deg2rad((360 / nb_points) * i)
		var point = angle_to_v2(angle) * radius
		points_array.append(point)
	
	return points_array


static func capsule2poly(height: float, radius: float) -> PoolVector2Array:
	var rect = Rect2(Vector2.ZERO, Vector2(radius * 2, height))
	var points_array = rect2poly(rect)
	
	var top_circle_center = Vector2(radius, 0)
	var bottom_circle_center = Vector2(radius, height)
	
	var nb_circle_points = 20
	for i in range(nb_circle_points):
		var angle = deg2rad((360 / nb_circle_points) * i)
		var point = angle_to_v2(angle) * radius
		
		if i == 0 or i == nb_circle_points / 2:
			continue

		if i < nb_circle_points / 2:
			point += bottom_circle_center
			points_array.insert(2 + i, point)
		else:
			point += top_circle_center
			points_array.insert(i - nb_circle_points / 2, point)
	
	return points_array


static func shape2rect(shape: Shape2D, global_transform: Transform2D) -> Rect2:
	if shape is RectangleShape2D:
		var rect = Rect2(-shape.get_extents(), shape.get_extents() * 2)
		return global_transform.xform(rect)
	else:
		return Rect2()


static func shape2poly(shape: Shape2D, global_transform: Transform) -> PoolVector2Array:
	if shape is RectangleShape2D:
		var rect = Rect2(Vector2.ZERO, shape.get_extents() * 2)
		return xform(global_transform, rect2poly(rect))
	
	elif shape is CircleShape2D:
		var poly = circle2poly(shape.radius)
		return xform(global_transform, poly)
	
	elif shape is ConvexPolygonShape2D:
		return xform(global_transform, shape.get_points())
	
	elif shape is ConcavePolygonShape2D:
		return xform(global_transform, shape.get_segments())
	
	elif shape is CapsuleShape2D:
		return xform(global_transform, capsule2poly(shape.height, shape.radius))
	
	elif shape is SegmentShape2D:
		return xform(global_transform, PoolVector2Array([shape.a, shape.b]))
	
	return PoolVector2Array()


static func xform(transform: Transform2D, v2_array: PoolVector2Array) -> PoolVector2Array:
	var result_array = PoolVector2Array()
	
	for v in v2_array:
		result_array.append(transform.xform(v))
	
	return result_array


static func circle_to_circle_intersection(p0: Vector2, r0: float, p1: Vector2, r1: float) -> PoolVector2Array:
	var points = PoolVector2Array()
	var d = p0.distance_to(p1)
	
	# The circles have no intersection at all
	if d > r0 + r1 or d < abs(r0 - r1):
		return points
	
	# The circle are the same: abort because it would return an infinity of points
	if is_equal_approx(d, 0.0) && is_equal_approx(r0, r1):
		push_warning("The two given circles have approximatly the same position & size; aborting")
		return points
	
	var a = (pow(r0, 2.0) - pow(r1, 2.0) + pow(d, 2.0)) / (2.0 * d)
	var p2 = p0 + a * (p1 - p0) / d
	
	# The circles have only one intersection
	if is_equal_approx(a, r0):
		points.append(p2)
		return points 
	
	var h = sqrt(pow(r0, 2.0) - pow(a, 2.0))
	var dx = p1.x - p0.x
	var dy = p1.y - p0.y
	var rx = -dy * (h / d)
	var ry = dx * (h / d)
	
	# The circle have two intersections
	for i in [-1, 1]:
		var x = p2.x + rx * i
		var y = p2.y + ry * i
		points.append(Vector2(x, y))
	
	return points


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


static func rdm_rect_point(rect: Rect2) -> Vector2:
	var point = Vector2(
		rand_range(0.0, rect.size.x),
		rand_range(0.0, rect.size.y)
	)
	
	return rect.position + point
