extends InteractiveObject
class_name Collectable

#warning-ignore:unused_signal
signal collect_animation_finished

onready var state_machine = $StatesMachine
onready var collect_particle = get_node_or_null("CollectParticle")

export var average_amount : int = 1
export(float, 0.0, 1.0) var amount_variance : float = 0.0

export var collectable_name : String = "" setget set_collectable_name, get_collectable_name

var target : Node = null setget set_target, get_target

#### ACCESSORS ####

func is_class(value: String): return value == "Collectable" or .is_class(value)
func get_class() -> String: return "Collectable"

func set_state(state): state_machine.set_state(state)
func get_state() -> Object: return state_machine.get_state()
func get_state_name(): return state_machine.get_state_name()

func set_collectable_name(value: String): collectable_name = value
func get_collectable_name() -> String: return collectable_name

func set_target(value: Node): target = value
func get_target() -> Node: return target

# FUNCTION OVERRIDE
func set_interactable(value: bool): 
	interactable = value
	
	# Desactivate the interact area
	if interact_area != null:
		interact_area.set_deferred("monitoring", value)
	
	var follow_area = get_node_or_null("FollowArea")
	if follow_area != null:
		follow_area.set_deferred("monitoring", value)


#### BUILT-IN ####

func _ready():
	var __ = connect("collect_animation_finished", self, "_on_collect_animation_finished")
	__ = $FollowArea.connect("body_entered", self, "_on_follow_area_body_entered")
	__ = interact_area.connect("body_entered", self, "_on_collect_area_body_entered")


#### VIRTUALS ####

#func interact():
#	collect()


func collect(_target: Node):
	set_target(_target)
	EVENTS.emit_signal("collect", self)


func follow(_target: Node):
	set_target(_target)
	set_state("Follow")


func trigger_collect_animation(_target: Node):
	set_target(_target)
	if !is_ready:
		default_state = "Collect"
	else:
		set_state("Collect")
	
	set_interactable(false)
	
	# Play the collect sound
	var audio_stream = get_node_or_null("CollectSound")
	if audio_stream != null:
		audio_stream.play()


#### LOGIC ####

func compute_amount_collected() -> int:
	return int(average_amount * (1 + rand_range(-amount_variance, amount_variance)))


#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_follow_area_body_entered(body: PhysicsBody2D):
	if body.is_class("Player"):
		follow(body)


func _on_collect_area_body_entered(body: PhysicsBody2D):
	if body == null:
		return
		
	if body.is_class("Player"):
		collect(body)


func _on_collect_animation_finished():
	EVENTS.emit_signal("collectable_amount_collected", self, compute_amount_collected())
	queue_free()
