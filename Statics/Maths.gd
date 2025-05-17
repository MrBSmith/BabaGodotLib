extends Node
class_name Maths

# Compare the two given directions (represented as Vector2), and check if their difference in angle is lesser than max_angle_diff
static func compare_dir(dir1: Vector2, dir2: Vector2, max_angle_diff: float) -> bool:
	if dir1 in [Vector2.ZERO, Vector2.INF] or dir2 in [Vector2.ZERO, Vector2.INF]:
		return false
	
	return abs(dir1.angle() - dir2.angle()) <= max_angle_diff


# Return 1 if the given bool is true, -1 if it's false
static func bool_to_sign(value: bool) -> int:
	return int(value) * 2 - 1


# Invert x and y members of the given Vector2
static func invert_v2(vec: Vector2) -> Vector2:
	return Vector2(vec.y, vec.x)


# Convert an angle (in radians) to a direction represented as a Vector2
static func angle_to_v2(angle: float) -> Vector2:
	return Vector2(cos(angle), sin(angle))


static func vec2_to_vec3(vec2: Vector2, z: float) -> Vector3:
	return Vector3(vec2.x, vec2.y, z)


static func vec2_from_vec3(vec3: Vector3) -> Vector2:
	return Vector2(vec3.x, vec3.y)


# Sums the distance between each points of the line to get its total lenght
# If to_id is -1 compute the line's total length
# If to_id is a valid id, compute the line's length from line[0] to line[to_id]
static func compute_line_length(line : Array[Vector2], to_id : int =  -1) -> float:
	var previous_point := Vector2.INF
	var total_dist : float = 0.0
	var max_id = line.size() if to_id == -1 else to_id + 1
	
	for i in range(max_id):
		var point = line[i]
		if previous_point != Vector2.INF:
			total_dist += previous_point.distance_to(point)
		
		previous_point = point
	return total_dist

# Find the nearest point of the line to the given point
static func find_line_nearest_point(point: Vector2, line: Array[Vector2]) -> Vector2:
	var nearest_point = Vector2.INF
	for line_point in line:
		if point.distance_to(line_point) < point.distance_to(nearest_point):
			nearest_point = line_point
	return nearest_point


# Find a random position inside the given rect
static func rdm_rect_point(rect: Rect2) -> Vector2:
	var point = Vector2(
		randf_range(0.0, rect.size.x),
		randf_range(0.0, rect.size.y)
	)
	
	return rect.position + point


static func circle_to_circle_intersection(p0: Vector2, r0: float, p1: Vector2, r1: float) -> Array[Vector2]:
	var points : Array[Vector2] = []
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


static func rect2poly(rect: Rect2) -> Array[Vector2]:
	return [
		rect.position,
		rect.position + rect.size * Vector2.RIGHT,
		rect.end,
		rect.position + rect.size * Vector2.DOWN
	]
