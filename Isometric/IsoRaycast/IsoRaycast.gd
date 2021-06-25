extends Node
class_name IsoRaycast


# Get every cells visible between the origin and the destination
static func get_line_of_sight(map: IsoMap, origin: Vector3, dest: Vector3, obj_ignored : Array = []) -> PoolVector3Array:
	var line = bresenham3D(origin.round(), dest.round())
	var line_of_sight = PoolVector3Array()
	
	for cell in line:
		if cell == line[0]: continue
		
		if !map.is_cell_free(cell):
			if map.is_cell_tile(cell) or map.is_cell_wall(cell) or map.is_occupied_by_obstacle(cell):
				line_of_sight.append(cell)
				break
			else:
				var obj = map.get_damagable_on_cell(cell)
				var obj_cell = obj.get_current_cell()
				line_of_sight.append(obj_cell)
				if not obj in obj_ignored:
					break
		else:
			line_of_sight.append(cell)
	
	return line_of_sight


static func bresenham3D(origin: Vector3, dest: Vector3) -> PoolVector3Array:
	var points_array := PoolVector3Array()
	points_array.append(origin)
	
	var dist_x = abs(dest.x - origin.x)
	var dist_y = abs(dest.y - origin.y)
	var dist_z = abs(dest.z - origin.z)
	
	var sign_x = 1 if dest.x > origin.x else -1
	var sign_y = 1 if dest.y > origin.y else -1
	var sign_z = 1 if dest.z > origin.z else -1
	
	# Driving axis is x
	if dist_x >= dist_y && dist_x >= dist_z:
		var p1 = 2 * dist_y - dist_x
		var p2 = 2 * dist_z - dist_x
		while(origin.x != dest.x):
			origin.x += sign_x
			if p1 >= 0:
				origin.y += sign_y
				p1 -= 2 * dist_x
			if p2 >= 0:
				origin.z += sign_z
				p2 -= 2 * dist_x
			p1 += 2 * dist_y
			p2 += 2 * dist_z
			points_array.append(origin)
	
	# Driving axis is y
	elif dist_y >= dist_x && dist_y >= dist_z:
		var p1 = 2 * dist_x - dist_y
		var p2 = 2 * dist_z - dist_y
		while(origin.y != dest.y):
			origin.y += sign_y
			if p1 >= 0:
				origin.x += sign_x
				p1 -= 2 * dist_y
			if p2 >= 0:
				origin.z += sign_z
				p2 -= 2 * dist_y
			p1 += 2 * dist_x
			p2 += 2 * dist_z
			points_array.append(origin)
	
	# Driving axis is z
	else:
		var p1 = 2 * dist_y - dist_z
		var p2 = 2 * dist_x - dist_z
		while(origin.z != dest.z):
			origin.z += sign_z
			if p1 >= 0:
				origin.y += sign_y
				p1 -= 2 * dist_z
			if p2 >= 0:
				origin.x += sign_x
				p2 -= 2 * dist_z
			p1 += 2 * dist_y
			p2 += 2 * dist_x
			points_array.append(origin)
	
	return points_array
