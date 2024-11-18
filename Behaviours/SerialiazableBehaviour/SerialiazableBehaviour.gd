extends Behaviour
class_name SerializableBehaviour

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

export var logger_path : NodePath
export(SETGET_MODE) var setget_mode : int = SETGET_MODE.PROPERTY
export(int, FLAGS, "checkpoint", "save", "game state online", "each tick online") var fetch_case_flag : int = 0x00
export(int, FLAGS, "checkpoint", "save", "game state online", "each tick online") var persistant_flag : int = 0x00
export var serialized_properties := PoolStringArray()

onready var logger = get_node(logger_path) if !logger_path.is_empty() else NullLogger.new()

var _handled_by_client := false setget set_handled_by_client, is_handled_by_client

var last_tick_state_received : float = 0.0
var nb_state_received : int = 0
var cumulated_delta : float = 0.0
var avg_reception_delta : float = INF

signal handled_by_client_changed

func is_class(value: String): return value == "SerializableBehaviour" or .is_class(value)
func get_class() -> String: return "SerializableBehaviour"

func set_handled_by_client(value: bool) -> void:
	if _handled_by_client != value:
		_handled_by_client = value
		emit_signal("handled_by_client_changed")
func is_handled_by_client() -> bool: return _handled_by_client

func must_fetch(fetch_case: int) -> bool:
	if fetch_case & FETCH_CASE_FLAG.GAME_STATE_ONLINE and NETWORK.is_online() and \
		!_is_handler_peer():
		return false
	
	return bool(fetch_case & fetch_case_flag)


func must_apply(fetch_case: int) -> bool:
	if fetch_case & FETCH_CASE_FLAG.GAME_STATE_ONLINE and NETWORK.is_online() and \
		_is_handler_peer():
		return false
	
	return bool(fetch_case & fetch_case_flag)


func _is_handler_peer() -> bool:
	return NETWORK.is_client() == _handled_by_client


func _ready() -> void:
	if fetch_case_flag & FETCH_CASE_FLAG.EACH_TICK_ONLINE:
		set_physics_process(true)
		var _err = EVENTS.connect("remote_peer_handled_state_received", self, "_on_EVENTS_remote_peer_handled_state_received")
	else:
		set_physics_process(false)


func _physics_process(_delta: float) -> void:
	print(serialize())
	
	if NETWORK.is_online() and NETWORK.is_client() == is_handled_by_client():
		NETWORK.emit_peer_handled_state_packet(get_path(), serialize())


func serialize() -> Dictionary:
	if disabled: return {}
	
	var dict = {}
	
	for property in serialized_properties:
		var holder_path = owner.get_path_to(holder)
		var property_path = NodePath(property) if ":" in property else NodePath("%s:%s" % [holder_path, property])
		dict[property_path] = _get_value(property_path)
	
	return dict


func deserialize(state: Dictionary) -> void:
	if disabled: return
	
	for property in state.keys():
		_set_value(property, state[property])


func _get_value(property_path: NodePath):
	var path = Utils.node_path_trim_property(property_path)
	var node = owner.get_node_or_null(path)
	
	if !node:
		push_error("Couldn't find node at path %s" % path)
		return
	
	var property = Utils.node_path_trim_path(property_path)
	
	match(setget_mode):
		SETGET_MODE.PROPERTY: return node.get(property)
		SETGET_MODE.ACCESSOR:
			var getter = "get_" + property
		
			if !node.has_method(getter):
				return node.get(property)
			
			return node.call(getter)


func _set_value(property_path: NodePath, value) -> void:
	var path = Utils.node_path_trim_property(property_path)
	var node = owner.get_node_or_null(path)
	
	if !node:
		push_error("Couldn't find node at path %s" % path)
		return
	
	var property = Utils.node_path_trim_path(property_path)
	
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
		logger.debug("Average state reception delta: %f" % avg_reception_delta)


func _on_EVENTS_remote_peer_handled_state_received(node_path: String, remote_state: Dictionary) -> void:
	if is_handled_by_client() == NETWORK.is_client():
		return
	
	if node_path == str(get_path()):
		if not logger is NullLogger: 
			_update_average_state_delta()
		
		deserialize(remote_state)
