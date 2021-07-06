tool
extends CanvasLayer
class_name WorldMap

onready var binds_container = $Binds
onready var characters_container = $Characters

onready var tween_node = $Tween
onready var cursor : Node2D = $WorldMapCursor

export var bind_scene_path : String = "res://BabaGodotLib/WorldMap/LevelNodeBind/LevelNodeBind.tscn"
export var cursor_start_level_path : String = "" 

onready var bind_scene = load(bind_scene_path)

var cursor_moving : bool = false

var is_ready : bool = false 

# warning-ignore:unused_signal
signal character_moving_feedback_finished

#### ACCESSORS ####

func is_class(value: String): return value == "WorldMap" or .is_class(value)
func get_class() -> String: return "WorldMap"


#### BUILT-IN ####

func _ready():
	is_ready = true
	init_cursor_position(null)

#### VIRTUALS ####



#### LOGIC ####


func init_cursor_position(level_node: LevelNode):
	var level = get_node_or_null(cursor_start_level_path) if level_node == null else level_node
	
	if level == null:
		push_error("the current level_node can't be found at path " + cursor_start_level_path)
		return
	
	cursor.set_current_node(level)
	cursor.set_global_position(level.get_global_position())
	characters_container.set_current_node(level)
	characters_container.set_global_position(level.get_global_position())


# Returns true if the two given nodes are connected by a bind
func are_level_nodes_bounded(level1: LevelNode, level2: LevelNode) -> bool:
	for bind in binds_container.get_children():
		var bind_nodes = [bind.get_origin(), bind.get_destination()]
		if level1 in bind_nodes && level2 in bind_nodes:
			return true
	return false


# Move the cursor based on the user input
func move_cursor(dir: Vector2):
	var adequate_node = find_adequate_node(dir)
	if adequate_node == null:
		return
	
	cursor.move_to_node(adequate_node)


# Find the node targeted by the user, based on the direction of his input and returns it
func find_adequate_node(dir: Vector2) -> WorldMapNode:
	var current_cursor_level = cursor.get_current_node()
	var level_node_binds = get_binds(current_cursor_level)
	
	for bind in level_node_binds:
		if bind.get_path_direction_form_node(current_cursor_level) == dir:
			if current_cursor_level == bind.get_origin():
				return bind.get_destination()
			else:
				return bind.get_origin()
	
	return null


func get_level_nodes() -> Array:
	var levels_array = []
	for child in $Levels.get_children():
		if child is LevelNode and not child in levels_array:
			levels_array.append(child)
	return levels_array


func _move_to_node(_node: WorldMapNode) -> void:
	pass


# Get every nodes connected to the given one by a bind
func get_bounded_level_nodes(node: LevelNode) -> Array:
	var binds_array = binds_container.get_children()
	var bounded_nodes_array := Array()
	
	for bind in binds_array:
		
		if bind.get_origin() == node:
			var dest = bind.get_destination()
			if not dest in bounded_nodes_array:
				bounded_nodes_array.append(dest)
		
		elif bind.get_destination() == node:
			var origin = bind.get_origin()
			if not origin in bounded_nodes_array:
				bounded_nodes_array.append(origin)
	
	return bounded_nodes_array


# Returns an arrayu containing all the binds of the given node
func get_binds(node: WorldMapNode) -> Array:
	var bind_array := Array()
	for bind in binds_container.get_children():
		if bind.get_origin() == node or bind.get_destination() == node:
			bind_array.append(bind)
	
	return bind_array


# Return the bind conencting the two given nodes
func get_bind(origin: WorldMapNode, dest: WorldMapNode) -> LevelNodeBind:
	for child in binds_container.get_children():
		var bind_nodes = [child.get_origin(), child.get_destination()]
		if origin in bind_nodes && dest in bind_nodes:
			return child
	return null


# Trigger the scene change to enter the level
func enter_current_level():
	var current_cursor_level = cursor.get_current_level()
	GAME.goto_level_by_path(current_cursor_level.get_level_scene_path())


func is_level_valid(level : LevelNode) -> bool:
	return level != null and \
	level.is_accessible() and \
	level.get_level_scene_path() != ""


func is_animation_running() -> bool:
	return characters_container.is_moving()


#### INPUTS ####

func _input(_event: InputEvent) -> void:
	if Engine.editor_hint or cursor_moving:
		return
	
	if Input.is_action_just_pressed("ui_right"):
		move_cursor(Vector2.RIGHT)
	
	if Input.is_action_just_pressed("ui_up"):
		move_cursor(Vector2.UP)
	
	if Input.is_action_just_pressed("ui_down"):
		move_cursor(Vector2.DOWN)
	
	if Input.is_action_just_pressed("ui_left"):
		move_cursor(Vector2.LEFT)
	
	if Input.is_action_just_pressed("ui_accept"):
		var cursor_node = cursor.get_current_node()
		
		if cursor_node is LevelNode:
			if is_level_valid(cursor_node) and !is_animation_running():
				enter_current_level()



#### SIGNAL RESPONSES ####


func _on_add_bind_query(origin: WorldMapNode, dest: WorldMapNode):
	var bind = bind_scene.instance()
	binds_container.add_child(bind)
	bind.owner = self
	
	bind.set_origin(origin)
	bind.set_destination(dest)


func _on_remove_all_binds_query(node: WorldMapNode):
	for bind in binds_container.get_children():
		if bind.get_origin() == node or bind.get_destination() == node:
			bind.queue_free()


func _on_level_node_hidden_changed(level_node: LevelNode, hidden: bool):
	var level_binds = get_binds(level_node)
	for bind in level_binds:
		var hidden_bind = true if hidden else bind.origin.is_hidden() or bind.destination.is_hidden()
		bind.set_hidden(hidden_bind)


func _on_level_visited(level_node : LevelNode):
	var bounded_nodes = get_bounded_level_nodes(level_node)
	for node in bounded_nodes:
		if node.is_hidden():
			node.set_hidden(false)
