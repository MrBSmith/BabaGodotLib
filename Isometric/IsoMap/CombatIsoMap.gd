tool
extends IsoMap
class_name CombatIsoMap

# A class to handle combat specific logic for IsoMap

onready var area_node = $Interactives/Areas

#### ACCESSORS ####


#### BUILT-IN ####


#### LOGIC ####


# Draw the movement of the given character
func draw_movement_area():
	var mov = owner.active_actor.get_current_movements()
	var current_cell = owner.active_actor.get_current_cell()
	var reachable_cells = pathfinding.find_reachable_cells(current_cell, mov)
	area_node.draw_area(reachable_cells, "move")


# Get the reachable cells in the given range. Returns a PoolVector3Array of visible & reachable cells
func get_visible_cells(origin: Vector3, h: int, ran: int, include_self_cell: bool = false) -> PoolVector3Array:
	var ranged_cells = get_cells_in_circle(origin, ran)

	var visible_cells := PoolVector3Array()
	
	if include_self_cell:
		visible_cells.append(origin)
	
	for i in range(ranged_cells.size()):
		var cell = ranged_cells[-i - 1]
		
		if cell in visible_cells: continue
		
		var line = IsoRaycast.get_line(self, origin, cell.round())
		var valid_cells = IsoRaycast.get_line_of_sight(self, h, line)
		
		for c in valid_cells:
			if (not c in visible_cells) && c in ranged_cells:
				visible_cells.append(c)
	
	return visible_cells


# Update the view field of the given actor by fetching every cells he can see and feed himù
func update_view_field(actor: IsoObject):
	var view_range = actor.get_view_range()
	var actor_cell = actor.get_current_cell()
	var actor_height = actor.get_height()
	
	var visible_cells = Array(get_visible_cells(actor_cell, actor_height, view_range, true))
	var barely_visible_cells = Array()
	
	for cell in visible_cells:
		if IsoLogic.iso_2D_dist(actor_cell, cell) == view_range - 1:
			barely_visible_cells.append(cell)
	
	for cell in barely_visible_cells:
		visible_cells.erase(cell)
	
	actor.set_view_field([
		visible_cells,
		barely_visible_cells])


# Return true if at least one target is reachable by the active actor
func has_target_reachable(actor: TRPG_Actor) -> bool:
	var visibles_cells = actor.get_view_field_v3_array()
	var attack_range = actor.get_current_range()
	var actor_cell = actor.get_current_cell()
	
	for cell in visibles_cells:
		var dist = IsoLogic.iso_2D_dist(actor_cell, cell)
		if dist > attack_range:
			continue
		
		var obj = get_object_on_cell(cell)
		if obj == null:
			continue
		
		if obj.is_in_group("Enemies") or obj.is_class("Obstacle"):
			return true
	
	return false


# Return the number of targets reachable by the active actor 
func count_reachable_enemies(active_cell: Vector3 = owner.active_actor.get_current_cell()) -> int:
	var actor_range = owner.active_actor.get_current_range()
	var reachables = get_cells_in_circle(active_cell, actor_range)
	var count : int = 0
	
	for cell in reachables:
		var obj = get_object_on_cell(cell)
		
		if obj == null:
			continue
		
		if obj.is_class("TRPG_Actor"):
			if obj.is_in_group("Enemies"):
				count += 1
	return count



# Return every cells at the given dist or more from the origin in the given array
func get_cells_in_circle(origin: Vector3, radius: int, 
		cells_array: PoolVector3Array = walkable_cells, ignore_origin: bool = false) -> PoolVector3Array:
	var cells_at_dist = PoolVector3Array()
	for cell in cells_array:
		if ignore_origin && cell == origin: continue
		var x_sum_diff = abs(cell.x - origin.x)
		var y_sum_diff = abs(cell.y - origin.y)
		var dif = x_sum_diff + y_sum_diff
		if dif < radius:
			cells_at_dist.append(cell)
	return cells_at_dist


# Returns every cell from the cells_array that are 
# in a straight line starting from origin and going in the given direction for the given lenght
func get_cells_in_straight_line(origin : Vector3, length: int, direction) -> PoolVector3Array:
	if direction is int && (direction < 0 or direction > 3):
		print_debug("the given direction: " + String(direction) + "is not valid.")
		return PoolVector3Array()
	
	var cells_in_line = PoolVector3Array()
	var dir_array = direction if direction is Array else [direction]
	
	for dir in dir_array:
		var vec_dir = IsoLogic.dir_to_vec2(dir)
		for i in range(length):
			var cell_2d = Vector2(origin.x, origin.y) + vec_dir * (i + 1)
			for cell in walkable_cells:
				if cell.x == cell_2d.x && cell.y == cell_2d.y:
					cells_in_line.append(cell)
	
	return cells_in_line


# Returns every cells in the cells_array that are
# in a perpendicular line of the given lenght, in the given direction
func get_cell_in_perpendicular_line(origin: Vector3, lenght: int, dir: int) -> PoolVector3Array:
	if dir < 0 or dir > 3 or Math.is_even(lenght):
		if Math.is_even(lenght): print_debug("The lenght must be an uneven number")
		else : print_debug("the given direction: " + String(dir) + "is not valid.")
		return PoolVector3Array()
	
	var cells_2D_array := PoolVector2Array()
	var cells_in_line = PoolVector3Array()
	var vec_dir = IsoLogic.dir_to_vec2(dir)
	var perpendicular_dir = vec_dir.rotated(0.5 * PI)
	
	for i in range(lenght):
		if i == 0:
			cells_2D_array.append(Vector2(origin.x, origin.y) + vec_dir)
		else:
			var offset_amount = int(float(i + 1) / 2)
			var current_dir = perpendicular_dir if Math.is_even(i + 1) else -perpendicular_dir
			cells_2D_array.append(cells_2D_array[0] + current_dir * offset_amount)
	
	for cell in walkable_cells:
		if Vector2(cell.x, cell.y) in cells_2D_array:
			cells_in_line.append(cell)
	
	return cells_in_line


func get_cells_in_square(origin: Vector3, size: int, dir: int) -> PoolVector3Array:
	var cells_in_square = PoolVector3Array()
	if dir < 0 or dir > 3:
		print_debug("The given dir: " + String(dir) + " isn't valid")
		return PoolVector3Array()
	
	var vec_dir = IsoLogic.dir_to_vec2(dir)
	var vec_dir_rotated = vec_dir.rotated(0.5 * PI)
	var square_dir = Vector2(vec_dir.x, vec_dir_rotated.y) if vec_dir.x != 0 else Vector2(vec_dir_rotated.x, vec_dir.y)
	
	for i in range(size):
		for j in range(size):
			var vec2 = Vector2(origin.x, origin.y) + Vector2(j, i) * square_dir
			cells_in_square.append(Vector3(vec2.x, vec2.y, get_cell_highest_layer(vec2)))
	
	return cells_in_square



func get_objects_in_area(area: PoolVector3Array) -> Array:
	var objects_array = Array()
	for cell in area:
		var obj = get_object_on_cell(cell)
		if obj != null:
			objects_array.append(obj)
	
	return objects_array


#### SIGNAL RESPONSES ####


func on_iso_object_cell_changed(iso_object: IsoObject):
	if iso_object.is_class("Ally"):
		update_view_field(iso_object)
