tool
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


export(int, FLAGS, "Godot console", "Game console") var output_flag = OUTPUT.GODOT_CONSOLE
export(int, FLAGS, "Editor", "Debug", "Release", "Tool") var mode_flag = MODE.TOOL

var active : bool = false
var _is_ready = false

func _ready() -> void:
	if OS.has_feature("editor") and mode_flag & MODE.EDITOR: active = true
	elif OS.has_feature("debug") and mode_flag & MODE.DEBUG: active = true
	elif OS.has_feature("release") and mode_flag & MODE.RELEASE: active = true
	elif Engine.editor_hint and mode_flag & MODE.TOOL: active = true
	
	_is_ready = true


func _push(msg: String, msg_type: int) -> void:
	if !_is_ready:
		yield(self, "ready")
	
	if !active and msg_type == MESSAGE_TYPE.DEBUG:
		return
	
	if output_flag & OUTPUT.GAME_CONSOLE: CONSOLE.push(msg, msg_type)
	if output_flag & OUTPUT.GODOT_CONSOLE:
		match(msg_type):
			MESSAGE_TYPE.DEBUG: print(msg)
			MESSAGE_TYPE.ERROR: push_error(msg)
			MESSAGE_TYPE.WARNING: push_warning(msg) 


func debug(msg: String) -> void:
	_push(msg, MESSAGE_TYPE.DEBUG)


func warning(msg: String) -> void:
	_push(msg, MESSAGE_TYPE.WARNING)


func error(msg: String) -> void:
	_push(msg, MESSAGE_TYPE.ERROR)

