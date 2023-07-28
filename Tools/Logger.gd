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


export(int, FLAGS, "Godot console", "Game console") var output_flag = OUTPUT.GODOT_CONSOLE
export(int, FLAGS, "Editor", "Debug", "Release", "Tool") var mode_flag = MODE.TOOL

var active : bool = false

func _ready() -> void:
	if OS.has_feature("Editor") and mode_flag & MODE.EDITOR: active = true
	elif OS.has_feature("Debug") and mode_flag & MODE.DEBUG: active = true
	elif OS.has_feature("Release") and mode_flag & MODE.RELEASE: active = true
	elif Engine.editor_hint and mode_flag & MODE.TOOL: active = true


func push(msg: String) -> void:
	if !active:
		return
	
	if output_flag & OUTPUT.GODOT_CONSOLE: CONSOLE.push(msg)
	if output_flag & OUTPUT.GAME_CONSOLE: print(msg)

