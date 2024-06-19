extends Node
class_name CollisionChecker


#### ACCESSORS ####



#### BUILT-IN ####



#### LOGIC ####

# Test if a collision occur between the caller, and the given entity
static func test_collision(caller : PhysicsBody2D, movement: Vector2, 
	collision2D: KinematicCollision2D, vertical: bool) -> bool:
	
	var collider = collision2D.get_collider()
	var collision_pos = collision2D.get_position()
	var collider_rect : Rect2
	var mov = Vector2(0.0, movement.y) if vertical else Vector2(movement.x, 0.0)
	
	var self_rect = get_body_rect(caller, movement)
	
	if collider is PhysicsBody2D:
		collider_rect = get_body_rect(collider)
	elif collider is TileMap:
		var tile_grid_pos = collider.world_to_map(collision_pos + mov)
		var cell_size = collider.cell_size
		collider_rect = Rect2(tile_grid_pos * cell_size, cell_size)
	
	return self_rect.intersects(collider_rect)


# Check for a wall collision behind the character
static func test_wall_collision(body: PhysicsBody2D, level: Level, movement: Vector2) -> bool:
	if movement.x == 0.0 or !body:
		return false
	
	var body_rect = get_body_rect(body, movement)
	
	var top_left_corner = body_rect.position
	var top_right_corner = body_rect.position + Vector2(body_rect.size.x, 0.0)
	
	if !level:
		return false
	
	var wall_tilemap = level.find_node("Walls")
	
	if !wall_tilemap:
		print("Walls Tilemap can't be found in the scene: " + level.name)
		return false
	
	var top_left_tilemap_pos = wall_tilemap.world_to_map(top_left_corner)
	var top_right_tilemap_pos = wall_tilemap.world_to_map(top_right_corner)
	var used_wall_cells = wall_tilemap.get_used_cells()
	
	return top_left_tilemap_pos in used_wall_cells or top_right_tilemap_pos in used_wall_cells


# Return the rect representing the hitbox of the given bodys
static func get_body_rect(body: PhysicsBody2D, movement := Vector2.ZERO) -> Rect2:
	var col_shape = body.get_node_or_null("CollisionShape2D")
	
	if col_shape == null:
		return Rect2()
	
	var shape = col_shape.get_shape()
	
	
	if !shape is RectangleShape2D:
		return Rect2(Vector2.ZERO, Vector2.ZERO)
	
	var extents = shape.get_extents()
	return Rect2(col_shape.get_global_position() - extents + movement, extents * 2)


#### VIRTUALS ####



#### INPUTS ####



#### SIGNAL RESPONSES ####
