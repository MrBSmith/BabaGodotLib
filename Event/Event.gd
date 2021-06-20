extends Node2D
class_name Event

### An abstract class for handling scritped events in your game
### This node sould have one or more Tigger node as a child
### Whenever the tiggered signal is received from one of its Trigger children
### and if event_disabled is false -> the virtual method event() is called

export var event_disabled : bool = false

func is_class(value: String): return value == "Event" or .is_class(value)
func get_class() -> String: return "Event"

# Get every TriggerArea child of this node and store them in the triggers_area_array
# Also connect every child's area_triggered signal
func _ready():
	for child in get_children():
		if child is Trigger:
			child.connect("triggered", self, "_on_trigger_triggered")


## Each time an area is triggered, check if every area is triggered
## If it is the case, call the event
#func on_area_triggered(_body):
#	if are_every_area_triggered():
#		event()
#
#
## Check if every area have been triggered, return true if yes, false if not
#func are_every_area_triggered() -> bool:
#	var value = true
#	for area in triggers_area_array:
#		if !area.is_triggered():
#			value = false
#
#	return value


# Here is what happens when every area has been triggered
func event():
	queue_free()


#### SIGNAL_RESPONSES ####

func _on_trigger_triggered():
	if !event_disabled:
		event()
