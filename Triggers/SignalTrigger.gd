extends Trigger
class_name SignalTrigger

export var instance_listened_path : String = ""
export var signal_to_listen : String = ""
var instance_listened : Object = null setget set_instance_listened, get_instance_listened

signal instance_listened_changed(new_instance)

#### ACCESSORS ####

func is_class(value: String): return value == "SignalTrigger" or .is_class(value)
func get_class() -> String: return "SignalTrigger"

func set_instance_listened(value: Object):
	if (value == null or is_instance_valid(value)) && value != instance_listened:
		instance_listened = value
		if instance_listened:
			emit_signal("instance_listened_changed", instance_listened)

func get_instance_listened() -> Object: return instance_listened

#### BUILT-IN ####

func _ready() -> void:
	var __ = connect("instance_listened_changed", self, "_on_instance_listened_changed")
	
	if instance_listened_path != "":
		var instance = get_tree().get_current_scene().get_node_or_null(instance_listened_path)
		if instance_listened == null:
			push_error("No node where found at the sepcified node path : %s" % instance_listened_path)
		else:
			set_instance_listened(instance)
	
	if instance_listened != null:
		await_instance_signal()


#### VIRTUALS ####



#### LOGIC ####

func await_instance_signal() -> void:
	if is_instance_valid(instance_listened) && instance_listened.has_signal(signal_to_listen):
		yield(instance_listened, signal_to_listen)
		trigger()



#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_instance_listened_changed(new_instance: Object):
	if new_instance != null:
		await_instance_signal()
