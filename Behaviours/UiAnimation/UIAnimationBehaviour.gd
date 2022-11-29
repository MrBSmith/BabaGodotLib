extends Behaviour
class_name UIAnimationBehaviour

@export var target_path : NodePath
@export var autostart : bool = false

@onready var target = owner if target_path.is_empty() else get_node(target_path)

var buffered_method : Callable
var animation_playing : bool = false
var is_ready := false

signal animation_started
signal animation_finished


#### ACCESSORS ####

func is_class(value: String): return value == "UIAnimationBehaviour" or super.is_class(value)
func get_class() -> String: return "UIAnimationBehaviour"


#### BUILT-IN ####

func _ready() -> void:
	animation_finished.connect(_on_animation_finished)
	
	for module in Utils.fetch_recursive(self, "UIAnimationModule"):
		module.target = target
	
	if autostart:
		trigger_animation()



#### VIRTUALS ####



#### LOGIC ####

func trigger_animation(backwards: bool = false) -> void:
	if animation_playing:
		buffered_method = trigger_animation.bind(backwards)
		return
	
	animation_started.emit()
	
	animation_playing = true
	var modules_array = get_children()
	
	if backwards:
		modules_array.reverse()
	
	for module in modules_array:
		if not module is UIAnimationModule && not module is ParallelModulePlayer:
			continue 
		
		if module.disabled:
			continue
		
		module.play()
		
		await module.animation_finished
	
	animation_playing = false
	animation_finished.emit()


#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_animation_finished() -> void:
	if is_instance_valid(buffered_method):
		buffered_method.call()
		buffered_method = null

