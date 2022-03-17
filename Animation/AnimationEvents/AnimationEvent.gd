extends Node
class_name AnimationEvent

# This class shall always be a child node of an AnimatedSprite
# It use is to react to certains animations key frame by doing a method call in the target node

# The event will be triggered if the animation with the name animation_name 
# is played in the parent AnimatedSprite and if the current frame's id is
# in the trigger_frames int array

# If the property subsequence_anim_name is set to true, the event will be triggered even
# if the animation_name is a subsequence of the name of the animation played by the AnimatedSprite

# The node is fetch via its path, stored in target_node_path,
# The method called shall be in the target_method variable and arguments can be passed

export var animation_name : String = ""
export var subsequence_anim_name : bool = false
export var trigger_frames := PoolIntArray()

export var target_node_path : String = ""
export var target_method : String = ""
export var arguments : Array = []

onready var parent = get_parent()

#### ACCESSORS ####

func is_class(value: String): return value == "AnimationEvent" or .is_class(value)
func get_class() -> String: return "AnimationEvent"


#### BUILT-IN ####

func _ready() -> void:
	if not parent is AnimatedSprite:
		push_warning("The AnimationEvent located at %s is not a child of an AnimatedSprite" % get_path())
		return
	
	var __ = parent.connect("frame_changed", self, "_on_animation_frame_changed")
	

#### VIRTUALS ####



#### LOGIC ####

func trigger_event() -> void:
	var target = owner.get_node(target_node_path)
	target.callv(target_method, arguments)


#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_animation_frame_changed() -> void:
	var animation = parent.get_animation()
	var frame = parent.get_frame()
	
	if (subsequence_anim_name && animation_name.is_subsequence_ofi(animation)) or \
			animation_name == animation:
		if frame in trigger_frames:
			trigger_event()
