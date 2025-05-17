extends Trait
class_name SerializableTrait

const NB_SAMPLES_FOR_AVG_DELTA = 2

enum SETGET_MODE {
	PROPERTY,
	ACCESSOR,
}

enum FETCH_CASE_FLAG {
	CHECKPOINT = 0x01,
	SAVE = 0x02,
	GAME_STATE_ONLINE = 0x04,
	EACH_TICK_ONLINE = 0x08,
}

@export var logger_path : NodePath
@export var setget_mode : SETGET_MODE = SETGET_MODE.PROPERTY
@export_flags("checkpoint", "save", "game state online", "each tick online") var fetch_case_flag : int = 0x00
@export_flags("checkpoint", "save", "game state online", "each tick online") var persistant_flag : int = 0x00
@export var serialized_properties : Array[String]
@export var immediate_packets := false

@export var is_online := false
@export var is_client := false

var _handled_by_client := false:
	set(value):
		if _handled_by_client != value:
			_handled_by_client = value
			handled_by_client_changed.emit()
func is_handled_by_client() -> bool: return _handled_by_client

var last_tick_state_received : float = 0.0
var nb_state_received : int = 0
var cumulated_delta : float = 0.0
var avg_reception_delta : float = INF

signal handled_by_client_changed

func must_fetch(fetch_case: int) -> bool:
	if fetch_case & FETCH_CASE_FLAG.GAME_STATE_ONLINE and is_online and !_is_handler_peer():
		return false
	
	return bool(fetch_case & fetch_case_flag)

func must_apply(fetch_case: int) -> bool:
	if fetch_case & FETCH_CASE_FLAG.GAME_STATE_ONLINE and is_online and _is_handler_peer():
		return false
	
	return bool(fetch_case & fetch_case_flag)

func _is_handler_peer() -> bool:
	return is_client == _handled_by_client


func serialize() -> Dictionary:
	var dict = {}
	
	for property in serialized_properties:
		var holder_path = owner.get_path_to(holder)
		var property_path = NodePath(property) if ":" in property else NodePath("%s:%s" % [holder_path, property])
		dict[property_path] = _get_value(property_path)
	
	return dict


func deserialize(state: Dictionary) -> void:
	for property in state.keys():
		_set_value(property, state[property])


func _get_value(property_path: NodePath):
	var path = property_path.get_concatenated_names()
	var node = owner.get_node_or_null(path)
	
	if !node:
		push_error("Couldn't find node at path %s" % path)
		return
	
	var property = property_path.get_concatenated_subnames()
	
	match(setget_mode):
		SETGET_MODE.PROPERTY: return node.get(property)
		SETGET_MODE.ACCESSOR:
			var getter = "get_" + property
		
			if !node.has_method(getter):
				return node.get(property)
			
			return node.call(getter)


func _set_value(property_path: NodePath, value) -> void:
	var path = property_path.get_concatenated_names()
	var node = owner.get_node_or_null(path)
	
	if !node:
		push_error("Couldn't find node at path %s" % path)
		return
	
	var property = property_path.get_concatenated_subnames()
	
	match(setget_mode):
		SETGET_MODE.PROPERTY: node.set(property, value)
		SETGET_MODE.ACCESSOR: 
			var setter = "set_" + property
		
			if !node.has_method(setter):
				node.set(property, value)
				return
			
			node.call(setter, value)


func _update_average_state_delta() -> void:
	var tick = Time.get_ticks_msec()
	cumulated_delta += tick - last_tick_state_received
	last_tick_state_received = tick
	nb_state_received += 1
	
	if nb_state_received >= NB_SAMPLES_FOR_AVG_DELTA:
		avg_reception_delta = cumulated_delta / NB_SAMPLES_FOR_AVG_DELTA
		cumulated_delta = 0.0
		nb_state_received = 0


func _on_EVENTS_remote_peer_handled_state_received(node_path: String, remote_state: Dictionary) -> void:
	if _is_handler_peer():
		return
	
	if node_path == str(get_path()):
		deserialize(remote_state)
