extends Label
class_name StateLabel

onready var states_machine : Node = get_parent()

#### ACCESSORS ####

func is_class(value: String): return value == "StateLabel" or .is_class(value)
func get_class() -> String: return "StateLabel"


#### BUILT-IN ####

func _ready():
	var _err = states_machine.connect("state_changed", self, "_on_state_changed")


#### SIGNAL RESPONSES ####

func _on_state_changed(state: Object):
	if state == null:
		text = ""
	else:
		text = state.name
