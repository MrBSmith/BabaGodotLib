extends Node2D
class_name IsoRenderer

var outline_shader = preload("res://BabaGodotLib/Shaders/IsoInnerOutline/IsoInnerOutline.tres")

# A Base class to render an IsoMap with multiple layers of height and its IsoObject in it
# Feed the renderer by giving it every layers of your map and every objects
# using the init_rendering_queue method

# The renderer create a RenderPart for each tile of the map, 
# and as many RenderPart it needs to render IsoObjects a the correct height
# for exemple a 2 tiles tall object will be scattered in 2 render parts

# The rendering then order each render part based on its cell position on the map
# Each time an object change cell, or an object is added or removed, 
# the renderer is informed by the iso_object_cell_changed, iso_object_added & iso_object_removed signals. 
# This is why it is mandatory to use IsoObject inherited objects for it to work with this renderer

onready var tween = $Tween
onready var rendering_queue = $RenderingQueue

var visible_cells : Array = [[], []] setget set_visible_cells, get_visible_cells
var focus_array : Array = [] setget set_focus_array, get_focus_array

var print_logs : bool = false

enum cell_comp {
	BEFORE,
	EQUAL,
	AFTER
}

enum type_priority {
	TILE,
	AREA,
	MOVEMENT_ARROW,
	CURSOR,
	OBSTACLE,
	ACTOR
}

#### ACCESSORS ####

func set_focus_array(array: Array): focus_array = array
func get_focus_array() -> Array: return focus_array

func set_visible_cells(value: Array):
#	var cell_difference = _find_visibile_cells_differences(visible_cells, value)
#
#	if visible_cells == [[], []]:
#		_update_tiles_visibility_brute_force(value)
#	else:
#		_update_tile_visibility_by_diff(cell_difference)
	visible_cells = value
	_update_tiles_visibility_brute_force(visible_cells)
func get_visible_cells() -> Array: return visible_cells


#### BUILT-IN ####

func _ready() -> void:
	var _err = EVENTS.connect("iso_object_cell_changed", self, "_on_iso_object_cell_changed")
	_err = EVENTS.connect("iso_object_height_changed", self, "_on_iso_object_height_changed")
	_err = EVENTS.connect("iso_object_added", self, "_on_iso_object_added")
	_err = EVENTS.connect("iso_object_removed", self, "_on_iso_object_removed")
	_err = EVENTS.connect("area_added", self, "_on_area_added")
	_err = EVENTS.connect("area_cleared", self, "_on_area_cleared")
	_err = EVENTS.connect("area_cell_removed", self, "_on_area_cell_removed")
	_err = EVENTS.connect("tiles_shake", self, "_on_tiles_shake")
	_err = EVENTS.connect("appear_transition", self, "_on_appear_transition")
	_err = EVENTS.connect("disappear_transition", self, "_on_disappear_transition")
	_err = EVENTS.connect("update_rendered_visible_cells", self, "_on_update_rendered_visible_cells")
	_err = EVENTS.connect("tile_added", self, "_on_iso_tilemap_tile_added")
	_err = EVENTS.connect("tile_removed", self, "_on_iso_tilemap_tile_removed")
	_err = EVENTS.connect("iso_tilemap_cleared", self, "_on_iso_tilemap_cleared")


#### LOGIC ####

func init_rendering_queue(layers_array: Array) -> void:
	for i in range(layers_array.size()):
		for cell in layers_array[i].get_used_cells():
			var height = i - int(is_cell_slope(cell, layers_array[i])) * 0.5
			add_cell_to_queue(cell, layers_array[i], height)
		
		for child in layers_array[i].get_children():
			var scatter = "obstacle".is_subsequence_ofi(child.name)
			for cell in child.get_used_cells():
				var height = i - int(is_cell_slope(cell, child)) * 0.5
				add_cell_to_queue(cell, child, height, scatter)


# Add the given cell to te rendering queue
func add_cell_to_queue(cell: Vector2, tilemap: TileMap, height: float, scatter: bool = false) -> void:
	var tileset = tilemap.get_tileset()
	var is_wall = "Wall".is_subsequence_ofi(tilemap.name) && tilemap.name != "Walls"
	var east_wall = "East".is_subsequence_ofi(tilemap.name)
	var is_ground = "Layer".is_subsequence_ofi(tilemap.name)
	var is_slope = is_cell_slope(cell, tilemap)
	
	var tile_size = tilemap.get_cell_size()
	var z_offset = 0 if tilemap is IsoMapLayer else 1
	
	# In case of a tile wall (Walls bellow tiles), offset the cell of the render part
	# So the wall's visibility is logical
	var cell_offset = Vector3(int(east_wall), int(!east_wall), -int(is_wall)) if is_wall else Vector3.ZERO
	var cell_3D = Vector3(cell.x, cell.y, height) + cell_offset
	
	# Get the tile id and the position of the cell in the autotile
	var tile_id = tilemap.get_cellv(cell)
	var tile_mode = tileset.tile_get_tile_mode(tile_id)
	var tile_region = tileset.tile_get_region(tile_id)
	var tile_tileset_pos = tile_region.position
	var subtile_size = tileset.autotile_get_size(tile_id) if tile_mode != TileSet.SINGLE_TILE else tile_region.size
	var nb_parts = 1 if !scatter else int(round(subtile_size.y / tile_size.y))
	var mod = tilemap.get_modulate()
	
	var stream_texture = tileset.tile_get_texture(tile_id)
	
	for i in range(nb_parts):
		var part_offset = Vector2(0, tile_size.y) * (nb_parts - i - 1)
		var part_size = subtile_size if !scatter else tile_size
		
		var atlas_texture = AtlasTexture.new()
		atlas_texture.set_atlas(stream_texture)
		
		var region_pos = tile_tileset_pos + part_offset
		var bitmask = 0
		
		if tile_mode != tileset.SINGLE_TILE:
			var autotile_coord = tilemap.get_cell_autotile_coord(int(cell.x), int(cell.y))
			region_pos += autotile_coord * subtile_size
			bitmask = tileset.autotile_get_bitmask(tile_id, autotile_coord)
		
		atlas_texture.set_region(Rect2(region_pos, part_size))
		
		# Set the texture to the right position
		var layer_offset = Vector2(0, -tile_size.y) * round(height) 
		var height_offset = Vector2(0, round(part_size.y / 2))
		var texture_offset = tileset.tile_get_texture_offset(tile_id)
		var offset = texture_offset + layer_offset + part_offset + height_offset
		var pos = tilemap.map_to_world(cell)
		
		var render_part = TileRenderPart.new(tilemap, atlas_texture, 
				  cell_3D + Vector3(0, 0, i + z_offset), pos, 0, offset, mod)
		
		# Dynamic outline
		if height > 0 && (is_ground or is_wall or is_slope):
			var has_right_neighbour = tilemap.get_cellv(cell + Vector2(0, -1)) != -1
			var has_left_neighbour = tilemap.get_cellv(cell + Vector2(-1, 0)) != -1
			var wall_corner = false 
			
			# Check for an inner corner situation in case of a wall
			if is_wall:
				var parent_tilemap = tilemap.get_parent()
				var cell_to_check = Vector2(1, -1) if east_wall else Vector2(-1, 1)
				wall_corner = parent_tilemap.get_cellv(cell + cell_to_check) != -1
			
			var needs_outline = !has_right_neighbour or !has_left_neighbour
			var is_outlined_left_wall : bool = is_wall && !east_wall && !has_left_neighbour && !wall_corner
			var is_outlined_right_wall : bool = east_wall && !has_right_neighbour && !wall_corner
			var no_neighbours : bool = !has_left_neighbour && !has_right_neighbour 
			
			if needs_outline && (!is_wall or is_outlined_left_wall or is_outlined_right_wall):
				
					render_part.set_material(outline_shader.duplicate())
					var region_size = tile_size + Vector2(0, tile_size.y - 8) * int(is_wall or is_slope)
					
					var mater = render_part.get_material()
					mater.set_shader_param("region_pos", region_pos)
					mater.set_shader_param("region_size", region_size)
					
					var shader_width = 1.0 if no_neighbours && is_ground else 0.5
					if is_wall: shader_width = 0.031
					
					var shader_height = 1.0 if bitmask == 0 else 0.5
					var shader_offset = 0.5 if (!has_right_neighbour && has_left_neighbour) else 0.0
					if east_wall: shader_offset = 0.969
					
					mater.set_shader_param("uv_part_size", Vector2(shader_width, shader_height))
					mater.set_shader_param("uv_origin", Vector2(shader_offset, 0.0))
		
		add_iso_rendering_part(render_part, tilemap)


func is_cell_slope(cell: Vector2, tilemap: TileMap) -> bool:
	var tileset : TileSet = tilemap.get_tileset()
	var tile_id : int = tilemap.get_cell(int(cell.x), int(cell.y))
	var tile_name = tileset.tile_get_name(tile_id)
	
	return "slope".is_subsequence_ofi(tile_name) or "stair".is_subsequence_ofi(tile_name)


# Add the given part in the rendering queue
func add_iso_rendering_part(part: RenderPart, obj: Node) -> void:
	if rendering_queue.get_child_count() == 0:
		add_part(part, obj)
	else:
		var children = rendering_queue.get_children()
		var correct_id = binary_search_part_id(children, part)
		add_part(part, obj)
		rendering_queue.move_child(part, correct_id)


# Use the binary search algorithm to find the position the given part should have in the rendering queue
func binary_search_part_id(queue: Array, part: RenderPart) -> int:
	var id = -1
	var min_id = 0
	var max_id = queue.size() - 1
	
	while(min_id <= max_id):
		id = int((min_id + max_id) / 2)
		if compare_parts(part, queue[id]):
			if id == 0 or id == max_id:
				break
			max_id = id
		else: 
			min_id = id + 1
	
	return id


# Use the binary search algorithm to find the given part of the given cell
func binary_search_cell(queue: Array, cell: Vector3) -> int:
	var id = -1
	var min_id = 0
	var max_id = queue.size() - 1
	
	while(min_id <= max_id):
		id = int((min_id + max_id) / 2)
		
		var comp = compare_cells(cell, queue[id].get_current_cell())
		if id == max_id:
			if comp == cell_comp.EQUAL: break
			else:
				id = -1
				break
		
		if comp in [cell_comp.EQUAL, cell_comp.BEFORE]:
			if comp == cell_comp.EQUAL:
				break
			max_id = id
		else: 
			min_id = id + 1
	return id


# Add the given part to the render queue
func add_part(part: RenderPart, obj: Node) -> void:
	part.set_name(obj.name)
	part.renderer = self
	rendering_queue.add_child(part)
	part.set_owner(self)
	obj.render_parts.append(part)


func _find_visibile_cells_differences(old: Array, new: Array) -> Array:
	var diff = [[], [], []]
	var new_combined = []
	var old_combined = []
	
	for i in range(new.size()):
		new_combined += new[i]
		old_combined += old[i]
	
	for i in range(old.size()):
		for cell in old[i]:
			if !(cell in new_combined):
				diff[IsoObject.VISIBILITY.NOT_VISIBLE].append(cell)
			else:
				if !(cell in new[i]):
					var id = IsoObject.VISIBILITY.VISIBLE if i == IsoObject.VISIBILITY.BARELY_VISIBLE else IsoObject.VISIBILITY.BARELY_VISIBLE
					diff[id].append(cell) 
		
		for cell in new[i]:
			if !(cell in old_combined):
				diff[i].append(cell)
	
	return diff


# Update the tile visibility based on the visibles cells
func _update_tiles_visibility_brute_force(view_field: Array) -> void:
	var queue = rendering_queue.get_children()
	
	for i in range(queue.size()):
		var child = queue[i]
		if child is TileRenderPart:
			var part_cell = child.get_current_cell().round()
			if part_cell in view_field[IsoObject.VISIBILITY.BARELY_VISIBLE]:
				child.set_visibility(IsoObject.VISIBILITY.BARELY_VISIBLE)
			elif not part_cell in view_field[IsoObject.VISIBILITY.VISIBLE]:
				child.set_visibility(IsoObject.VISIBILITY.NOT_VISIBLE)
			else:
				child.set_visibility(IsoObject.VISIBILITY.VISIBLE)
	
	if print_logs:
		print("Update tile visibility with brute force strategy took %d iterations" % rendering_queue.get_child_count())


func _update_tile_visibility_by_diff(cell_diff: Array) -> void:
	var queue = rendering_queue.get_children()
	var total_iter = 0
	for i in range(cell_diff.size()):
		for cell in cell_diff[i]:
			var part_id = binary_search_cell(queue, cell)
			if part_id == -1: continue
			var part = rendering_queue.get_child(part_id)
			if part is TileRenderPart: part.set_visibility(i)
			total_iter += 1
	
	if print_logs:
		print("Update tile visibility with by difference strategy took %d iterations" % total_iter)


# Place the given obj at the right position in the rendering queue
func add_iso_obj(obj: IsoObject) -> void:
	var parts_array = scatter_iso_object(obj)
	
	for part in parts_array:
		add_iso_rendering_part(part, obj)


# Remove the given object from the rendering queue
func remove_parts_of_obj(obj: Object) -> void:
	for part in obj.render_parts:
		if is_instance_valid(part):
			part.queue_free()
	
	obj.render_parts = []


# Replace the given obj at the right position in the rendering queue
func reorder_iso_obj(obj: IsoObject) -> void:
	for part in obj.render_parts:
		reorder_part(part)


# Replace the given part at the right position in the rendering queue
func reorder_part(part: RenderPart) -> void:
	var queue = rendering_queue.get_children()
	queue.erase(part)
	var dest_id = binary_search_part_id(queue, part)
	
	if dest_id > part.get_index():
		dest_id += 1
	
	rendering_queue.move_child(part, dest_id)


func remove_part_at_cell(cell: Vector3, obj: Node = null) -> void:
	for child in rendering_queue.get_children():
		if obj != null && child.get_object_ref() != obj:
			continue
		
		if child.current_cell.x == cell.x && child.current_cell.y == cell.y:
			child.queue_free()


# Scatters a texture in the given number of smaller height, then returns it in an array
## ONLY HANDLE VERTICAL SCATTERING - MULTIPLE TILES WIDE OBJECTS ARE NOT SUPPORTED ##
func scatter_iso_object(obj: IsoObject) -> Array:
	var scattered_obj : Array = []
	var sprite_array : Array = []
	
	get_every_iso_sprites(obj, sprite_array)
	
	var height = obj.get_height()
	var obj_cell = obj.get_current_cell()
	var object_pos = obj.get_global_position()
	
	var obj_modul = obj.get_modulate()
	
	for i in range(height):
		var altitude = height - i
		var part_cell = obj_cell + Vector3(0, 0, altitude)
		
		var part = IsoRenderPart.new(obj, sprite_array, part_cell, object_pos,
									altitude, obj_modul)
		scattered_obj.append(part)
	
	return scattered_obj


# Get every children IsoSprite or IsoAnimatedSprite of the given node recursivly
func get_every_iso_sprites(obj: Node, array: Array) -> void:
	for child in obj.get_children():
		if (child is IsoSprite or child is IsoAnimatedSprite) && not obj in array:
			array.append(child)
		else:
			get_every_iso_sprites(child, array)


# Check if the given object have at least one part of it in the rendering queue
func is_obj_in_rendering_queue(obj: IsoObject) -> bool:
	for child in rendering_queue.get_children():
		if child.get_object_ref() == obj:
			return true
	return false 


# Return the value of the drawing priority of the given object type
func get_type_priority(thing) -> int:
	if thing.get_object_ref().is_class("TileMap"):
		if thing.get_object_ref().name == "Area":
			return type_priority.AREA
		else:
			return type_priority.TILE
	elif thing.get_object_ref().is_class("MovementArrowSegment"):
		return type_priority.MOVEMENT_ARROW
	elif thing.get_object_ref().is_class("Cursor"):
		return type_priority.CURSOR
	elif thing.get_object_ref().is_class("Obstacle"):
		return type_priority.OBSTACLE
	elif thing.get_object_ref().is_class("TRPG_Actor"):
		return type_priority.ACTOR
	
	return -1


func compare_cells(a: Vector3, b: Vector3) -> int:
	if a == b: return cell_comp.EQUAL
	var sum_result = xyz_sum_compare(a, b)
	
	if sum_result == cell_comp.EQUAL:
		if xyz_priority(a, b): return cell_comp.BEFORE
		else: return cell_comp.AFTER
	else: return sum_result


func xyz_sum_compare(a: Vector3, b: Vector3) -> int:
	var sum_a = a.x + a.y + a.z
	var sum_b = b.x + b.y + b.z
	
	if sum_a == sum_b: return cell_comp.EQUAL
	elif sum_a < sum_b: return cell_comp.BEFORE
	else: return cell_comp.AFTER


# If the type are the same compare z, then y, then x
func xyz_priority(a: Vector3, b: Vector3) -> bool:
	if a.z == b.z:
		if a.y == b.y:
			 return a.x < b.x
		else: return a.y < b.y
	else: return a.z < b.z


# Compare two positions, return true if a must be renderer before b
func compare_parts(a: RenderPart, b: RenderPart) -> bool:
	var cell_a = a.get_current_cell()
	var cell_b = b.get_current_cell()
	
	var sum_result = xyz_sum_compare(cell_a, cell_b)
	
	# First compare the sum x + y + z
	# Then sort by type 
	# If the type are the same compare z, then y, then x
	if sum_result == cell_comp.EQUAL:
		if get_type_priority(a) == get_type_priority(b):
			return xyz_priority(cell_a, cell_b)
		else: return get_type_priority(a) < get_type_priority(b)
	else: return sum_result == cell_comp.BEFORE


# Returns the parts at the given 2D position
func get_parts_at_2D_pos(pos: Vector2) -> Array:
	var part_array = Array()
	for child in rendering_queue.get_children():
		var child_cell = child.get_current_cell()
		if child_cell.x == pos.x && child_cell.y == pos.y:
			part_array.append(child)
	return part_array


# Returns an array of stacks ordered by x and y
func get_parts_stack_by_2D_order() -> Array:
	var top_most_part = rendering_queue.get_child(0)
	var top_most_cell = top_most_part.get_current_cell()
	
	var bottom_most_part = rendering_queue.get_child(rendering_queue.get_child_count() - 1)
	var bottom_most_cell = bottom_most_part.get_current_cell()
	var parts_stack_array := Array()
	
	for i in range(top_most_cell.y, bottom_most_cell.y + 1):
		for j in range(top_most_cell.x, bottom_most_cell.x + 1):
			var stack = get_parts_at_2D_pos(Vector2(j, i))
			if !stack.empty():
				parts_stack_array.append(stack)
	
	return parts_stack_array


func get_stack_by_2D_dist(corner := Vector2.DOWN) -> Array:
	var parts_stack_array := Array()
	
	var top_most_part = rendering_queue.get_child(0)
	var top_most_cell = top_most_part.get_current_cell()
	
	var bottom_most_part = rendering_queue.get_child(rendering_queue.get_child_count() - 1)
	var bottom_most_cell = bottom_most_part.get_current_cell()
	var max_dist = abs(top_most_cell.x + bottom_most_cell.x) + abs(top_most_cell.y + bottom_most_cell.y)
	
	var origin = top_most_cell
	var iteration_dir = Vector2.ONE
	
	match(corner):
		Vector2.RIGHT: 
			origin = Vector2(bottom_most_cell.x, top_most_cell.y)
			iteration_dir = Vector2(-1, 1)
		Vector2.LEFT: 
			origin = Vector2(top_most_cell.x, bottom_most_cell.y)
			iteration_dir = Vector2(1, -1) 
		Vector2.DOWN: 
			origin = bottom_most_cell
			iteration_dir = -Vector2.ONE
	
	for dist in range(max_dist + 1):
		for i in range(dist, -1, -1):
			var stack = get_parts_at_2D_pos(Vector2(origin.x + (dist - i) * iteration_dir.x, origin.y + i * iteration_dir.y))
			if !stack.empty():
				parts_stack_array.append(stack)
	
	return parts_stack_array


func add_area(map: IsoMap, cell_array: PoolVector3Array) -> void:
	var layers_array = map.get_layers_array()
	
	for cell in cell_array:
		var height = round(cell.z)
		var layer = layers_array[height]
		var area = layer.get_node("Area")
		add_cell_to_queue(Vector2(cell.x, cell.y), area, height)


func clear_tiles() -> void:
	for render_part in rendering_queue.get_children():
		if render_part.get_object_ref() is TileMap:
			render_part.destroy()


#### ANIMATION ####

# Apply a tile shake effect
func shake(origin: Vector2, magnitude: int, duration: float = 1.0) -> void:
	for part in rendering_queue.get_children():
		var part_cell = part.get_current_cell()
		var dist_to_origin = abs(part_cell.x - origin.x) + abs(part_cell.y - origin.y)
		if dist_to_origin <= magnitude:
			var mag = int(clamp(magnitude - dist_to_origin, 0, magnitude))
			var delay = (duration / 3) * (dist_to_origin / 2)
			tween.start_sin_move(part, mag, duration, 1, delay)


func appear_transition(total_time: float = 4.0, tile_order := Vector2.DOWN) -> void:
	var stack_array = get_stack_by_2D_dist(tile_order)
	var appear_delay = total_time / stack_array.size()
	
	for i in range(stack_array.size()):
		for j in range(stack_array[i].size()):
			stack_array[i][j].appear((i + j * 2) * appear_delay)


func disappear_transition(total_time: float = 4.0) -> void:
	var stack_array = get_stack_by_2D_dist()
	var appear_delay = total_time / stack_array.size()
	
	for i in range(stack_array.size()):
		for j in range(stack_array[i].size()):
			stack_array[i][j].disappear((i + j * 2) * appear_delay)


#### SIGNAL RESPONSES ####


func _on_iso_object_cell_changed(obj: IsoObject) -> void:
	if !is_obj_in_rendering_queue(obj):
		add_iso_obj(obj)


func _on_iso_object_height_changed(obj: IsoObject, from: int, to: int) -> void:
	if to > from:
		var parts_array = obj.render_parts.duplicate()
		for part in parts_array:
			part.destroy()
	
		add_iso_obj(obj)


func _on_iso_object_added(obj: IsoObject) -> void:
	add_iso_obj(obj)


func _on_iso_object_removed(obj: IsoObject) -> void:
	remove_parts_of_obj(obj)


func _on_part_cell_changed(part: IsoRenderPart, _cell: Vector3) -> void:
	reorder_part(part)


func _on_tiles_shake(origin: Vector2, magnitude: int) -> void:
	shake(origin, magnitude)


func _on_appear_transition() -> void:
	appear_transition()


func _on_disappear_transition() -> void:
	disappear_transition()


func _on_update_rendered_visible_cells(view_field: Array) -> void:
	set_visible_cells(view_field)


func _on_area_added(map: IsoMap, cell_array: PoolVector3Array) -> void:
	add_area(map, cell_array)


func _on_area_cell_removed(tilemap: TileMap, cell: Vector3) -> void:
	remove_part_at_cell(cell, tilemap)


func _on_area_cleared(map: IsoMap) -> void:
	var layers_array = map.get_layers_array()
	for i in range(layers_array.size()):
		var layer = layers_array[i]
		var area = layer.get_node("Area")
		remove_parts_of_obj(area)


func _on_click_at_cell_event(cell: Vector3) -> void:
	shake(Vector2(cell.x, cell.y), 3, 0.2)


func _on_iso_tilemap_tile_added(tilemap: IsoTileMap, cell: Vector3) -> void:
	add_cell_to_queue(Vector2(cell.x, cell.y), tilemap, cell.z)


func _on_iso_tilemap_tile_removed(tilemap: IsoTileMap, cell: Vector3) -> void:
	remove_part_at_cell(cell, tilemap)


func _on_iso_tilemap_cleared(tilemap: IsoTileMap) -> void:
	remove_parts_of_obj(tilemap)
