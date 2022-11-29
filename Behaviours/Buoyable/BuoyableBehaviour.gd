extends Behaviour
class_name BuoyableBehaviour

# A behaviour to apply buoyancy to objects
# Must be attached to a RigidBody2D for it to work
# You must provide the path of the body's CollisionShape2D for it to work

const DEFAULT_LIQUID_MASS : float = 0.000227202 * 1.069

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var draw_obj_polygons := false
@export var draw_intersection_polygons := true

@export var submerged_gravity_scale : float = 1.5

@export var collision_shape_path : NodePath = ""
@onready var collision_shape : CollisionShape2D = get_node(collision_shape_path)

@onready var total_obj_volume = Math.compute_polygon_surface(collision_shape.get_shape().get_points())
@onready var owner_default_gravity_scale = owner.gravity_scale

var liquid_collision_shape : CollisionShape2D = null

var body_polygon := PackedVector2Array()
var liquid_polygon := PackedVector2Array()
var intersect_polygon_array := Array()

#### ACCESSORS ####

func is_class(value: String): return value == "BuoyableBehaviour" or super.is_class(value)
func get_class() -> String: return "BuoyableBehaviour"


#### BUILT-IN ####

func _process(_delta: float) -> void:
	if liquid_collision_shape == null or collision_shape == null:
		return
	
	body_polygon = collision_shape.get_global_transform() * collision_shape.get_shape().get_points()
	liquid_polygon = Math.rect_shape_to_polygon(liquid_collision_shape.get_shape(), liquid_collision_shape.get_global_transform())
	intersect_polygon_array = Geometry2D.intersect_polygons(body_polygon, liquid_polygon)
	
	var submerged_surface = Math.compute_polygon_surface(intersect_polygon_array[0]) if !intersect_polygon_array.is_empty() else 0.0
	
	if draw_intersection_polygons or draw_obj_polygons:
		queue_redraw()
	
	_apply_buoyancy(submerged_surface)


func _draw() -> void:
	if draw_obj_polygons:
		if !body_polygon.is_empty():
			draw_polygon(body_polygon * global_transform, [Color(1.0, 0.0, 0.0, 0.5)])
		
		if liquid_polygon:
			draw_polygon(liquid_polygon * global_transform, [Color(0.0, 0.0, 1.0, 0.5)])
	
	if draw_intersection_polygons:
		for poly in intersect_polygon_array:
			if !poly.is_empty():
				draw_polygon(poly * global_transform, [Color.YELLOW])


#### VIRTUALS ####



#### LOGIC ####

func _apply_buoyancy(submerged_surface: float) -> void:
	var submerged_volume_ratio = submerged_surface / total_obj_volume
	
	owner.set_gravity_scale(lerp(submerged_gravity_scale, owner_default_gravity_scale, 1.0 - submerged_volume_ratio))
	var displaced_mass = DEFAULT_LIQUID_MASS * submerged_surface
	var force = Vector2.UP * displaced_mass * (gravity * owner.gravity_scale)
	
	owner.set_applied_force(Vector2.ZERO)
	owner.apply_central_force(force)





#### INPUTS ####



#### SIGNAL RESPONSES ####
