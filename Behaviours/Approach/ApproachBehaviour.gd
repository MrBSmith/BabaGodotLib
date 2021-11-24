extends Behaviour
class_name ApproachBehaviour

# This Behaviour is meant to notify when a certain type of body enters/exits its Area2D
# by sending body_approached and body_moved_away signals
# wanted_body_class defines the type the body should be in order to trigger the signals

# It can also have a Baba_Raycast2D as a child. In such case the raycast will
# check if the body is in clear line of sight before sending the body_approached signal

onready var raycast = get_node_or_null("Baba_Raycast2D")

export var wanted_body_class : String = "Player"
var tracked_bodies : Array = []

signal body_approached(body)
signal body_moved_away(body)

#### ACCESSORS ####

func is_class(value: String): return value == "ApproachBehaviour" or .is_class(value)
func get_class() -> String: return "ApproachBehaviour"


#### BUILT-IN ####

func _ready() -> void:
	if raycast:
		var __ = raycast.connect("target_found", self, "_on_Raycast_target_found")

#### VIRTUALS ####



#### LOGIC ####

func is_body_tracked(body: Node2D) -> bool:
	return body in tracked_bodies


func is_tracked_bodies_empty() -> bool:
	return tracked_bodies.empty()


func _track_body(body: Node2D) -> void:
	tracked_bodies.append(body)
	emit_signal("body_approached", body)


#### INPUTS ####



#### SIGNAL RESPONSES ####


func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_class(wanted_body_class) && not body in tracked_bodies:
		if raycast:
			raycast.search_for_target(body)
		else:
			_track_body(body)


func _on_Area2D_body_exited(body: Node) -> void:
	if body.is_class(wanted_body_class) && body in tracked_bodies:
		tracked_bodies.erase(body)
		emit_signal("body_moved_away", body)


func _on_Raycast_target_found(target: Node2D) -> void:
	_track_body(target)
