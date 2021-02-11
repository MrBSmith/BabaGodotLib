extends InteractiveObject
class_name Collectable

#warning-ignore:unused_signal
signal collect_animation_finished

onready var state_machine = $StatesMachine
onready var collect_particle = get_node_or_null("CollectParticle")

export var average_amount : int = 1
export(float, 0.0, 1.0) var amount_variance : float = 0.0

#### ACCESSORS ####

func is_class(value: String): return value == "Collectable" or .is_class(value)
func get_class() -> String: return "Collectable"

func set_state(state): state_machine.set_state(state)
func get_state() -> StateBase: return state_machine.get_state(0)
func get_state_name(): return state_machine.get_state_name()

#### BUILT-IN ####

func _ready():
	var __ = connect("collect_animation_finished", self, "_on_collect_animation_finished")
	__ = $FollowArea.connect("body_entered", self, "_on_follow_area_body_entered")
	__ = interact_area.connect("body_entered", self, "_on_collect_area_body_entered")


#### VIRTUALS ####

func interact():
	collect()


func collect():
	Events.emit_signal("collect", self)

func follow(target: Node2D):
	$StatesMachine/Follow.set_target(target)
	set_state("Follow")


func trigger_collect_animation(target_pos: Vector2):
	$StatesMachine/Collect.set_target_position(target_pos)
	
	if !is_ready:
		default_state = "Collect"
	else:
		set_state("Collect")
	
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
	if body is Player:
		follow(body)

func _on_collect_area_body_entered(body: PhysicsBody2D):
	if body is Player:
		collect()

func _on_collect_animation_finished():
	queue_free()
