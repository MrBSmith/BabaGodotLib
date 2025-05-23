@tool
extends Node
class_name Logger

enum OUTPUT {
	GODOT_CONSOLE = 1,
	GAME_CONSOLE = 2
}

enum MODE {
	EDITOR = 1,
	DEBUG = 2,
	RELEASE = 4,
	TOOL = 8
}

enum MESSAGE_TYPE {
	DEBUG,
	WARNING,
	ERROR
}

@export_flags("Godot console", "Game console") var output_flag : int = OUTPUT.GODOT_CONSOLE
@export_flags("Editor", "Debug", "Release", "Tool") var mode_flag : int = MODE.TOOL

var active : bool = false
var _is_ready = false

func _ready() -> void:
	if OS.has_feature("editor") and mode_flag & MODE.EDITOR: active = true
	elif OS.has_feature("debug") and mode_flag & MODE.DEBUG: active = true
	elif OS.has_feature("release") and mode_flag & MODE.RELEASE: active = true
	elif Engine.is_editor_hint() and mode_flag & MODE.TOOL: active = true
	
	_is_ready = true


func _push(msg: String, msg_type: int) -> void:
	if !_is_ready:
		await ready
	
	if !active and msg_type == MESSAGE_TYPE.DEBUG:
		return
	
	var console = get_tree().get_root().get_node_or_null("CONSOLE")
	
	if output_flag & OUTPUT.GAME_CONSOLE:
		if console:
			console.push(msg, msg_type)
		else:
			push_warning("No autoload CONSOLE found, cannot push log to it")
	if output_flag & OUTPUT.GODOT_CONSOLE:
		match(msg_type):
			MESSAGE_TYPE.DEBUG: print(msg)
			MESSAGE_TYPE.ERROR: push_error(msg)
			MESSAGE_TYPE.WARNING: push_warning(msg) 


func log(msg: String) -> void:
	_push(msg, MESSAGE_TYPE.DEBUG)


func warning(msg: String) -> void:
	_push(msg, MESSAGE_TYPE.WARNING)


func error(msg: String) -> void:
	_push(msg, MESSAGE_TYPE.ERROR)
