extends Behaviour
class_name UIAnimationBehaviour

export var target_path : NodePath
export var autostart : bool = false

onready var target = owner if target_path.is_empty() else get_node(target_path)

var buffered_method : BufferedMethod
var animation_playing : bool = false
var is_ready := false

signal animation_finished

class BufferedMethod:
	var func_ref : FuncRef
	var args = []
	
	func _init(_func_ref: FuncRef, _args: Array) -> void:
		func_ref = _func_ref
		args = _args
	
	func call_method() -> void:
		func_ref.call_funcv(args)


#### ACCESSORS ####

func is_class(value: String): return value == "UIAnimationBehaviour" or .is_class(value)
func get_class() -> String: return "UIAnimationBehaviour"


#### BUILT-IN ####

func _ready() -> void:
	var __ = connect("animation_finished", self, "_on_animation_finished")
	
	for module in Utils.fetch_recursive(self, "UIAnimationModule"):
		module.target = target
	
	if autostart:
		trigger_animation()



#### VIRTUALS ####



#### LOGIC ####

func trigger_animation(backwards: bool = false) -> void:
	if animation_playing:
		buffered_method = BufferedMethod.new(funcref(self, "trigger_animation"), [backwards])
		return
	
	animation_playing = true
	var modules_array = get_children()
	
	if backwards:
		modules_array.invert()
	
	for module in modules_array:
		if module.disabled:
			continue
		
		module.play()
		
		yield(module, "animation_finished")
	
	animation_playing = false
	emit_signal("animation_finished")


#### INPUTS ####


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") && !event.is_echo():
		trigger_animation()


#### SIGNAL RESPONSES ####

func _on_animation_finished() -> void:
	if is_instance_valid(buffered_method):
		buffered_method.call_method()
		buffered_method = null

