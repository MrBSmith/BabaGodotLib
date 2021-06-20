extends Trigger
class_name AreaTrigger

export var wanted_class : String = "Player"

var instance_triggering : Node2D = null

#### ACCESSORS ####

func is_class(value: String): return value == "AreaTrigger" or .is_class(value)
func get_class() -> String: return "AreaTrigger"


#### BUILT-IN ####

func _ready() -> void:
	for child in get_children():
		if child is Area2D:
			var __ = child.connect("body_entered", self, "_on_area_body_entered")
			__ = child.connect("area_entered", self, "_on_area_area_entered")

#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_area_body_entered(body: Node2D) -> void:
	if body.is_class(wanted_class) && body != owner:
		instance_triggering = body
		trigger()


func _on_area_area_entered(area: Area2D) -> void:
	if area.is_class(wanted_class) && area != owner:
		instance_triggering = area
		trigger()
