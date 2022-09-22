tool
extends WorldMapNode
class_name LevelNode

onready var tween_node = $Tween
onready var default_state : String = "Hidden" if hidden else "Visible" 

export var level_scene_path : String = "" setget , get_level_scene_path
export var level_name : String = "" setget set_level_name, get_level_name

export var hidden : bool = false setget set_hidden, is_hidden
export var visited : bool = false setget set_visited, is_visited

export var label_accessible_color : Color
export var label_unaccessible_color : Color

var is_ready := false

signal hidden_changed(level_node, hidden_value)
signal level_visited(level_node)


#### ACCESSORS ####

func is_class(value: String): return value == "LevelNode" or .is_class(value)
func get_class() -> String: return "LevelNode"

func set_visited(value: bool):
	visited = value
	if visited: 
		set_modulate(Color.darkgray)
		emit_signal("level_visited", self)
	else: set_modulate(Color.white)
func is_visited() -> bool: return visited

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
		emit_signal("hidden_changed", self, hidden)
func is_hidden() -> bool : return hidden

func get_level_scene_path() -> String: return level_scene_path

func set_level_name(value: String): 
	level_name = value
	if !is_inside_tree():
		yield(self, "ready")
	$Label.set_text(level_name)
func get_level_name() -> String: return level_name

func set_state(value): $StateMachine.set_state(value)
func get_state() -> State: return $StateMachine.get_state()
func get_state_name() -> String: return $StateMachine.get_state_name()

#### BUILT-IN ####

func _ready() -> void:
	if owner == null: return
	yield(owner, "ready")
	
	var __ = connect("hidden_changed", owner, "_on_level_node_hidden_changed")
	__ = connect("level_visited", owner, "_on_level_visited")
	
	if !Engine.editor_hint:
		if material != null:
			material.set_local_to_scene(true)
	
	emit_signal("accessible_changed")
	
	is_ready = true


#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_accessible_changed() -> void:
	._on_accessible_changed()
	
	var label_color = label_accessible_color if accessible else label_unaccessible_color
	$Label.set_self_modulate(label_color)
