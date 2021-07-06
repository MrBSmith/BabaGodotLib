tool
extends Path2D
class_name LevelNodeBind

onready var tween_node : Tween = $Tween 
onready var line : Line2D = get_node_or_null("BindLine")
onready var default_state : String = "Hidden" if hidden else "Visible" 

export var origin_node_path : String = ""
export var destination_node_path : String = ""

export var hidden : bool = false setget set_hidden, is_hidden
export var angled_bind : bool = true

var origin : Node2D setget set_origin, get_origin
var destination : Node2D setget set_destination, get_destination

var origin_pos := Vector2.INF setget set_origin_pos
var dest_pos := Vector2.INF setget set_dest_pos

var point_path := PoolVector2Array() setget , get_point_path
var line_points_array = PoolVector2Array()

var is_ready : bool = false
var print_logs : bool = false

signal level_node_added()

#### ACCESSORS ####

func is_class(value: String): return value == "LevelNodeBind" or .is_class(value)
func get_class() -> String: return "LevelNodeBind"

func set_origin(value: Node2D):
	if origin == value: 
		return
	
	if origin != null:
		origin.disconnect("position_changed", self, "_on_level_node_position_changed")
	
	origin = value
	set_origin_pos(origin.position)
	var __ = origin.connect("position_changed", self, "_on_level_node_position_changed")
	
	if print_logs:
		print("Origin added: %s" % origin.name)
	
	emit_signal("level_node_added")
	if origin_node_path == "" && owner != null:
		origin_node_path = owner.get_path_to(origin)
	
	if origin == null:
		origin_pos = Vector2.INF

func get_origin() -> Node2D: return origin

func set_destination(value: Node2D): 
	if destination == value: 
		return
	
	if destination != null:
		destination.disconnect("position_changed", self, "_on_level_node_position_changed")
	
	destination = value
	set_dest_pos(destination.position)
	var __ = destination.connect("position_changed", self, "_on_level_node_position_changed")
	
	if print_logs:
		print("destination added: %s" % destination.name)
	
	emit_signal("level_node_added")
	if destination_node_path == "" && owner != null:
		destination_node_path = owner.get_path_to(destination)
	
	if destination == null:
		dest_pos = Vector2.INF
func get_destination() -> Node2D: return destination

func set_origin_pos(value: Vector2):
	if value != origin_pos:
		origin_pos = value
		if print_logs:
			print("origin_pos changed" + String(origin_pos))

func set_dest_pos(value: Vector2):
	if value != dest_pos:
		dest_pos = value
		if print_logs:
			print("dest_pos changed" + String(dest_pos))

func get_point_path() -> PoolVector2Array: return point_path

func set_hidden(value: bool): 
	if !is_ready:
		hidden = value
		return
	
	if value != hidden:
		hidden = value
		if Engine.editor_hint:
			if hidden:
				set_modulate(Color(1, 1, 1, 0.2))
			else:
				set_modulate(Color.white)
		else:
			if value:
				set_state("Disappear")
			else:
				set_state("Appear")

func is_hidden() -> bool : return hidden

func set_state(value): $StatesMachine.set_state(value)
func get_state() -> Object: return $StatesMachine.get_state()
func get_state_name() -> String: return $StatesMachine.get_state_name()


#### BUILT-IN ####

func _ready() -> void:
	var __ = connect("level_node_added", self, "_on_level_node_added")
	
	if line == null:
		line = Line2D.new()
		add_child(line)
	
	set_curve(Curve2D.new())
	
	is_ready = true
	
	if owner != null && origin_node_path != "" && destination_node_path != "":
		set_origin(owner.get_node(origin_node_path))
		set_destination(owner.get_node(destination_node_path))
	
	_update_line()

func _process(_delta: float) -> void:
	if origin != null && destination != null:
		set_origin_pos(origin.get_global_position())
		set_dest_pos(destination.get_global_position())


#### VIRTUALS ####



#### LOGIC ####


func _update() -> void:
	if is_instance_valid(origin) && is_instance_valid(destination):
		_update_line()
		if print_logs:
			print("The bind got its origin and dest: updating")


func _update_line():
	if Vector2.INF in [origin_pos, dest_pos]:
		if print_logs:
			print("Bind: The origin_pos and/or the dest_pos is not set: abort update")
		return
	
	point_path = PoolVector2Array()
	line_points_array = PoolVector2Array()
	point_path.append(origin_pos)
	
	if angled_bind:
		var x_dist = abs(origin_pos.x - dest_pos.x)
		var y_dist = abs(origin_pos.y - dest_pos.y)
		
		if x_dist != 0.0 && y_dist != 0.0:
			if x_dist > y_dist:
				point_path.append(Vector2(origin_pos.x, dest_pos.y))
			else:
				point_path.append(Vector2(dest_pos.x, origin_pos.y))
	
	point_path.append(dest_pos)
	
	curve.clear_points()
	for i in range(point_path.size()):
		var point = point_path[i]
		var dir = Vector2.ZERO
		var cap_offset = 0.0
		var node_texture = null
		var node_scale
		
		if i == 0:
			dir = point_path[0].direction_to(point_path[1])
			node_texture = origin.get_texture()
			node_scale = origin.get_scale()
		
		if i == point_path.size() - 1:
			dir = point_path[i].direction_to(point_path[i - 1])
			node_texture = destination.get_texture()
			node_scale = destination.get_scale()
		
		if node_texture != null:
			var texture_extent = node_texture.get_size() * node_scale / 2
			if dir.x != 0:
				cap_offset = texture_extent.x
			else:
				cap_offset = texture_extent.y
		
		var point_pos = point + (cap_offset + 6) * dir
		line_points_array.append(point_pos)
		curve.add_point(point_pos)
	
	if line.has_method("set_end_cap_node") && line.has_method("set_start_cap_node"):
		line.set_end_cap_node(destination)
		line.set_start_cap_node(origin)
	
	if print_logs:
		print("The bind got %d points" % line_points_array.size())
	
	line.set_points(line_points_array)
	
	if print_logs:
		print("Bind update finished")


func reroll_line_gen():
	line.update_children_binds()


# Return the direction the path of the bind is aiming to, based on the given level_node 
func get_path_direction_form_node(node: WorldMapNode) -> Vector2:
	if !angled_bind:
		var dir = origin.direction_to(destination)
		if node == destination:
			dir = -dir
		return dir
	else:
		var path = get_point_path()
		if node == destination:
			path.invert()
		
		if path.size() <= 1:
			return Vector2.ZERO
		
		var point_dir = path[0].direction_to(path[1])
		return point_dir


#### INPUTS ####



#### SIGNAL RESPONSES ####


func _on_level_node_added() -> void:
	_update()


func _on_level_node_position_changed() -> void:
	if print_logs:
		print("Level node dropped")
	
	_update()
