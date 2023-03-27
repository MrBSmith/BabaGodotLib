extends CollectableBehaviour
class_name FollowCollectable

onready var state_machine = get_node("StateMachine")
onready var raycast = get_node_or_null("Baba_RayCast2D")

export var default_state : String = ""

var speed := 0.0
export var acceleration := 10.0

#### ACCESSORS ####

func is_class(value: String): return value == "FollowCollectable" or .is_class(value)
func get_class() -> String: return "FollowCollectable"

func set_state(state): state_machine.set_state(state)
func get_state() -> Object: return state_machine.get_state()
func get_state_name(): return state_machine.get_state_name()

#### BUILT-IN ####

func _ready() -> void:
	var __ = $FollowArea.connect("body_entered", self, "_on_follow_area_body_entered")
	__ = $FollowArea.connect("body_exited", self, "_on_follow_area_body_exited")
	
	if raycast:
		raycast.connect("target_found", self, "_on_raycast_target_found")

#### VIRTUALS ####



#### LOGIC ####

func collect() -> void:
	.collect()
	set_state("Collect")
	EVENTS.emit_signal("collect", owner, collectable_name)


func follow_target(new_target: Node):
	if $AnimationPlayer.has_animation("Follow"):
		$AnimationPlayer.play("Follow")
	
	set_target(new_target)
	set_state("Follow")



#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_follow_area_body_entered(body: Node):
	if is_disabled():
		return
	
	if raycast != null:
		raycast.search_for_target(body)
	else:
		follow_target(body)


func _on_follow_area_body_exited(_body: Node):
	if $FollowArea.get_overlapping_bodies().empty():
		raycast.set_enabled(false)


func _on_raycast_target_found(target: Node) -> void:
	follow_target(target)
	raycast.set_enabled(false)

