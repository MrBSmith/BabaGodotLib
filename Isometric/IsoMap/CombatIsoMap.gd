tool
extends IsoMap
class_name CombatIsoMap

# A class to handle combat specific logic for IsoMap


#### ACCESSORS ####


#### BUILT-IN ####


#### LOGIC ####


func draw_movement_area(actor: TRPG_Actor) -> PoolVector3Array:
	var mov = actor.get_current_movements()
	var current_cell = actor.get_current_cell()
	var reachable_cells = pathfinding.find_reachable_cells(current_cell, mov)
	draw_area(reachable_cells)
	
	return reachable_cells


# Draw the movement of the given character
func draw_area(cells_array: PoolVector3Array, area_type: String = "Target") -> void:
	var cell_added = []
	
	for cell in cells_array:
		var alt = round(cell.z)
		var layer = get_layer(alt)
		var tilemap : TileMap = layer.get_node("Area")
		var tileset : TileSet = tilemap.get_tileset()
		var tile_id = tileset.find_tile_by_name(area_type.capitalize())
		if tilemap.get_cell(cell.x, cell.y) != tile_id:
			tilemap.set_cell(cell.x, cell.y, tile_id)
			cell_added.append(cell)
	
	for layer in layers_array:
		var tilemap : TileMap = layer.get_node("Area")
		tilemap.update_bitmask_region()
	
	EVENTS.emit_signal("area_added", self, cell_added)


func clear_area(area_type : String = "") -> void:
	for layer in layers_array:
		var tilemap : TileMap = layer.get_node("Area")
		if area_type == "":
			tilemap.clear()
			EVENTS.emit_signal("area_cleared", self)
		else:
			var area_type_id = tilemap.get_tileset().find_tile_by_name(area_type)
			
			for cell in tilemap.get_used_cells():
				var tile_id = tilemap.get_cellv(cell)
				if area_type_id == tile_id:
					tilemap.set_cellv(cell, -1)
					EVENTS.emit_signal("area_cell_removed", tilemap, Vector3(cell.x, cell.y, layer.get_index()))


# Get the reachable cells in the given range. Returns a PoolVector3Array of visible & reachable cells
func get_visible_cells(origin: Vector3, h: int, ran: int, 
			include_self_cell: bool = false, obj_ignored : Array = []) -> PoolVector3Array:
	
	var ranged_cells = IsoLogic.get_cells_in_sphere(origin, ran - 1)
	
	if !owner.fog_of_war:
		return ranged_cells
	
	var visible_cells := PoolVector3Array()
	
	if include_self_cell:
		visible_cells.append(origin)
	
	for i in range(ranged_cells.size()):
		var cell = ranged_cells[-i - 1]
		
		if cell in visible_cells or is_cell_free(cell): 
			continue
		
		var valid_cells = IsoRaycast.get_line_of_sight(self, origin + Vector3(0, 0, h), cell.round(), obj_ignored)
		
		for c in valid_cells:
			if not c in visible_cells:
				visible_cells.append(c)
	
	return visible_cells


# Update the view field of the given actor by fetching every cells he can see and feed him
func update_view_field(actor: IsoObject) -> void:
	if !is_ready: 
		return
	
	var view_range = actor.get_view_range()
	var actor_cell = actor.get_current_cell()
	var actor_height = actor.get_height()
	
	var visible_cells = Array(get_visible_cells(actor_cell, actor_height, view_range, true, [actor]))
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
	var reachable_cells = []
	var attack_range = actor.get_current_range()
	var actor_cell = actor.get_current_cell()
	
	if owner.fog_of_war:
		reachable_cells = actor.get_view_field_v3_array()
	else:
		reachable_cells = IsoLogic.get_cells_in_sphere(actor_cell, attack_range + 1)
	
	for cell in reachable_cells:
		# Remove cells in view_field but too far away to be reached
		if owner.fog_of_war:
			var dist = IsoLogic.iso_2D_dist(actor_cell, cell)
			if dist > attack_range:
				continue

		var obj = get_damagable_on_cell(cell)
		if obj == null or obj == actor:
			continue
		
		if (obj.is_class("TRPG_Actor") && actor.get_team_side() != obj.get_team_side())\
			or obj.is_class("Obstacle"):
			return true
	
	return false


# Get every TRPG_DamagableObject in range of the given actor that is not in same team
# You can pass a actor_cell as an argument if you whant to check the targetables the actor would have
# If it was on the given cell, if nothing is passed, the function will use the current_cell of the actor
func get_targetables_in_range(actor: TRPG_Actor, actor_range: int, 
	actor_cell := Vector3.INF, same_team := false, include_self := false) -> Array:
	
	var targetables = []
	
	if actor_cell == Vector3.INF: actor_cell = actor.get_current_cell()
	var reachables = get_walkable_cells_in_circle(actor_cell, actor_range + 1, true)
	reachables.append(actor_cell)
	
	for cell in reachables:
		var obj = get_damagable_on_cell(cell)
		
		if obj == null:
			continue
		
		if obj.is_class("TRPG_DamagableObject"):
			if obj.is_class("TRPG_Actor"):
				if (actor.get_team() == obj.get_team()) != same_team:
					continue
			
			if not obj in targetables:
				if (obj == actor && !include_self):
					continue
				
				if actor.get_team().is_cell_in_view_field(obj.get_current_cell()):
					targetables.append(obj)
	
	return targetables


# Find the targets that are targetables (ie a path of the given lenght exists) among the given target_array
func get_reachable_targets(actor: TRPG_Actor, actor_range: int, target_array: Array) -> Array:
	var targetables = []
	for target in target_array:
		var path = pathfinding.find_path_to_reach(actor.get_current_cell(), target.get_current_cell())
		if path.size() <= actor_range && path.size() != 0:
			targetables.append(target)
	return targetables


# Return the number of targets reachable by the active actor if it was at the given cell
# if no cell is passed, the function will use the current_cell of the given actor
func count_reachable_enemies(actor: TRPG_Actor, cell:= Vector3.INF) -> int:
	var actor_range = actor.get_current_range()
	if cell == Vector3.INF: cell = actor.get_current_cell()
	var targetables = get_targetables_in_range(actor, actor_range, cell)
	return targetables.size()


# Return every cells at the given dist or more from the origin in the given array
func get_walkable_cells_in_circle(origin: Vector3, radius: int, ignore_origin: bool = false,
		cells_array: PoolVector3Array = walkable_cells) -> PoolVector3Array:
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
			cells_in_square.append(Vector3(vec2.x, vec2.y, get_cell2D_highest_z(vec2)))
	
	return cells_in_square


# Return an array of opponents (Actors of an opponent team) in the given range (on a 2D plane)
func get_nearby_opponents(actor: TRPG_Actor, dist_range: int, currently_visible: bool = false) -> Array:
	var actor_team = actor.get_team()
	var actor_team_side = actor.get_team_side()
	var cells_in_range = get_cells_in_range(actor.get_current_cell(), dist_range)
	var opponents_array = []
	
	for cell in cells_in_range:
		var damagable = get_damagable_on_cell(cell)
		
		if damagable != null && damagable.is_class("TRPG_Actor"):
			if damagable.get_team_side() != actor_team_side:
				if currently_visible:
					var damagable_cell = damagable.get_current_cell()
					if !actor_team.is_cell_in_view_field(damagable_cell):
						continue
				
				opponents_array.append(damagable)
	
	return opponents_array


# Return every TRPG_DamagableObject in the given aoe_target
func get_damagable_in_area(aoe_target: AOE_Target) -> Array:
	var targetables := Array()
	var cells_array = get_cells_in_area(aoe_target)
	for cell in cells_array:
		var target = get_damagable_on_cell(cell)
		if target != null:
			targetables.append(target)
	return targetables


# Get an PoolVector3Array of the cells in the given aoe
func get_cells_in_area(aoe_target: AOE_Target) -> PoolVector3Array:
	if aoe_target == null:
		push_error("aoe_target is null")
		return PoolVector3Array()
	
	var aoe = aoe_target.aoe
	var origin_cell = aoe_target.origin_cell
	var target_cell = aoe_target.target_cell
	var aoe_dir = aoe_target.aoe_dir
	
	var dir = IsoLogic.iso_dir(origin_cell, target_cell)
	match(aoe_target.aoe.area_type.name):
		"LineForward": return get_cells_in_straight_line(origin_cell, aoe.area_size, dir)
		"LnePerpendicular": return get_cell_in_perpendicular_line(origin_cell, aoe.area_size, dir)
		"Circle": return get_walkable_cells_in_circle(target_cell, aoe.area_size)
		"Square": return get_cells_in_square(target_cell, aoe.area_size, aoe_dir)
	
	return PoolVector3Array()


# Get every DamagableObjects in the given area (represented by a PoolVector3Array of cells)
func get_objects_in_area(area: PoolVector3Array) -> Array:
	var objects_array = Array()
	for cell in area:
		var obj = get_damagable_on_cell(cell)
		if obj != null:
			objects_array.append(obj)
	
	return objects_array


#### SIGNAL RESPONSES ####


func on_iso_object_cell_changed(iso_object: IsoObject):
	if iso_object.is_class("TRPG_Actor") && iso_object.is_team_side(ActorTeam.TEAM_TYPE.ALLY):
		if owner.fog_of_war:
			update_view_field(iso_object)
