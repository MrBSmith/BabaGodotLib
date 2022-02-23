extends Trigger
class_name AreaTrigger

func is_class(value: String): return value == "AreaTrigger" or .is_class(value)
func get_class() -> String: return "AreaTrigger"

onready var areatrigger_node : Area2D = $Area2D

export var wanted_robot : String = ""
var instance_triggering : Node2D = null

var both_players : bool = false
var triggerable : bool = true

#### ACCESSORS ####


#### BUILT-IN ####

func _ready() -> void:
	if is_instance_valid(areatrigger_node):
		var __ = areatrigger_node.connect("body_entered", self, "_on_area_body_entered")
		__ = areatrigger_node.connect("area_entered", self, "_on_area_area_entered")


func setup() -> void:
	if both_players:
		var __ = areatrigger_node.connect("body_exited", self, "_on_area_body_exited")
		__ = areatrigger_node.connect("area_exited", self, "_on_area_area_exited")



#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_area_body_entered(body: PhysicsBody2D) -> void:
	if !is_instance_valid(body) or not body is ActorBase:
		return

	if (body.get_name() == wanted_robot or body.is_class(wanted_robot) or wanted_robot == "") && body != owner:
		instance_triggering = body
		if triggerable:
			trigger()
		else:
			triggerable = true


func _on_area_area_entered(area: Area2D) -> void:
	if !is_instance_valid(area):
		return
		
	if (area.get_name() == wanted_robot or area.is_class(wanted_robot)) && area != owner:
		instance_triggering = area
		
		if triggerable:
			trigger()
		else:
			triggerable = true


func _on_area_body_exited(body: PhysicsBody2D) -> void:
	if !is_instance_valid(body):
		return
	
	if (body.get_name() == wanted_robot or body.is_class(wanted_robot)) and body != owner:
		triggerable = false


func _on_area_area_exited(area: Area2D) -> void:
	if !is_instance_valid(area):
		return
	
	if (area.get_name() == wanted_robot or area.is_class(wanted_robot)) and area != owner:
		triggerable = false
