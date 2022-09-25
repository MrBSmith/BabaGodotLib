tool
extends CanvasLayer
class_name WorldMap

const GARAGE_SCENE_PATH = "res://Scenes/Garage/Garage.tscn"

onready var level_node_container = $Levels
onready var binds_container = $Binds
onready var characters_container = $Characters

onready var tween_node = $Tween
onready var cursor : Node2D = $WorldMapCursor

export var bind_scene_path : String = "res://BabaGodotLib/WorldMap/LevelNodeBind/LevelNodeBind.tscn"
export var cursor_start_level_path : String = "" 

onready var bind_scene = load(bind_scene_path)

var cursor_moving : bool = false
var buffered_cursor_move := Vector2.ZERO

export var print_logs := true
var is_ready : bool = false 

# warning-ignore:unused_signal
signal character_moving_feedback_finished
signal world_map_node_removed(node)

#### ACCESSORS ####

func is_class(value: String): return value == "WorldMap" or .is_class(value)
func get_class() -> String: return "WorldMap"


#### BUILT-IN ####

func _ready():
	is_ready = true
	init_cursor_position(null)
	
	var __ = cursor.connect("back_to_idle", self, "_on_cursor_back_to_idle")


func _enter_tree() -> void:
	var __ = get_tree().connect("node_removed", self, "_on_node_removed")


func _exit_tree() -> void:
	get_tree().disconnect("node_removed", self, "_on_node_removed")


#### VIRTUALS ####



#### LOGIC ####


func init_cursor_position(level_node: LevelNode) -> void:
	var level = get_node_or_null(cursor_start_level_path) if level_node == null else level_node
	
	if level == null:
		push_error("the current level_node can't be found at path " + cursor_start_level_path)
		return
	
	cursor.set_current_node(level)
	cursor.set_global_position(level.get_global_position())
	characters_container.set_current_node(level)
	characters_container.set_global_position(level.get_global_position())


# Returns true if the two given nodes are connected by a bind
func are_level_nodes_bounded(node1: WorldMapNode, node2: WorldMapNode) -> bool:
	for bind in binds_container.get_children():
		var bind_nodes = [bind.get_origin(), bind.get_destination()]
		if node1 in bind_nodes && node2 in bind_nodes:
			return true
	return false


# Returns true if the two given nodes designated by their id are connected by a bind
func are_level_nodes_bounded_id(node1_id: int, node2_id: int) -> bool:
	var nb_nodes = level_node_container.get_child_count()
	if node1_id > nb_nodes - 1 or node2_id > nb_nodes - 1 or node1_id < 0 or node2_id < 0:
		push_warning("One of the given node_id is out of bounds")
		return false
	
	var node1 = level_node_container.get_child(node1_id)
	var node2 = level_node_container.get_child(node2_id)
	return are_level_nodes_bounded(node1, node2)


# Move the cursor based on the user input
func move_cursor(dir: Vector2):
	if cursor.get_state_name() == "Move":
		buffered_cursor_move = dir
		return
	
	var adequate_node = find_adequate_node(dir)
	if adequate_node == null:
		return
	
	if adequate_node.is_accessible():
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
	var current_cursor_level = cursor.get_current_node()
	var path = current_cursor_level.get_level_scene_path()
	if path == GARAGE_SCENE_PATH:
		GAME._go_to_garage()
	else:
		EVENTS.emit_signal("go_to_level_by_path", path)


func is_level_valid(level : LevelNode) -> bool:
	return level != null and \
	level.is_accessible() and \
	level.get_level_scene_path() != ""


func is_animation_running() -> bool:
	return characters_container.is_moving()


#### INPUTS ####

func _input(_event: InputEvent) -> void:
	if Engine.editor_hint or GAME.cutscene_playing:
		return
	
	if Input.is_action_just_pressed("ui_right"):
		move_cursor(Vector2.RIGHT)
	
	if Input.is_action_just_pressed("ui_up"):
		move_cursor(Vector2.UP)
	
	if Input.is_action_just_pressed("ui_down"):
		move_cursor(Vector2.DOWN)
	
	if Input.is_action_just_pressed("ui_left"):
		move_cursor(Vector2.LEFT)
	
	if Input.is_action_just_pressed("ui_accept") && !cursor_moving:
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
	if print_logs:
		print("remove binds associated with the node %s" % node)
	
	for bind in binds_container.get_children():
		if print_logs:
			print("Node's name: %s " % node.name)
			print("Bind's origin is node: %s" % bind.get_origin().name)
			print("Bind's destination is node: %s" % bind.get_destination().name)
		
		if bind.get_origin() == node or bind.get_destination() == node:
			if print_logs: print("Bind removed: %s" % bind.name)
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


func _on_node_removed(node: Node) -> void:
	if node is WorldMapNode:
		emit_signal("world_map_node_removed", node)


func _on_cursor_back_to_idle() -> void:
	if buffered_cursor_move != Vector2.ZERO:
		move_cursor(buffered_cursor_move)
		buffered_cursor_move = Vector2.ZERO
