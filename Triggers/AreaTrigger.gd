extends Trigger
class_name AreaTrigger

func is_class(value: String): return value == "AreaTrigger" or .is_class(value)
func get_class() -> String: return "AreaTrigger"

onready var areatrigger_node : Area2D = $Area2D

export var wanted_robot : String = ""
var instance_triggering : Node2D = null

#### ACCESSORS ####


#### BUILT-IN ####

func _ready() -> void:
	if is_instance_valid(areatrigger_node):
		var __ = areatrigger_node.connect("body_entered", self, "_on_area_body_entered")
		__ = areatrigger_node.connect("area_entered", self, "_on_area_area_entered")

#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_area_body_entered(body: PhysicsBody2D) -> void:
	if !is_instance_valid(body):
		return

	if (body.get_name() == wanted_robot or body.is_class(wanted_robot))  && body != owner:
		instance_triggering = body
		trigger()


func _on_area_area_entered(area: Area2D) -> void:
	if !is_instance_valid(area):
		return
		
	if (area.get_name() == wanted_robot or area.is_class(wanted_robot)) && area != owner:
		instance_triggering = area
		trigger()
