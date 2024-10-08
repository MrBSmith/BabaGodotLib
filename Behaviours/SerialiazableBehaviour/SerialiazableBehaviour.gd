extends Behaviour
class_name SerializableBehaviour

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

export(SETGET_MODE) var setget_mode : int = SETGET_MODE.PROPERTY
export(int, FLAGS, "checkpoint", "save", "game state online", "each tick online") var fetch_case_flag : int = 0x00
export(int, FLAGS, "checkpoint", "save", "game state online", "each tick online") var persistant_flag : int = 0x00
export var serialized_properties := PoolStringArray()

var _handled_by_client := false setget set_handled_by_client, is_handled_by_client

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
	if NETWORK.is_online() and NETWORK.is_client() == is_handled_by_client():
		NETWORK.emit_peer_handled_state_packet(get_path(), serialize())


func serialize() -> Dictionary:
	if disabled: return {}
	
	var dict = {}
	
	for property in serialized_properties:
		dict[property] = _get_value(property)
	
	return dict


func deserialize(state: Dictionary) -> void:
	if disabled: return
	
	if NETWORK.is_client() and _handled_by_client:
		return
	
	for property in state.keys():
		_set_value(property, state[property])


func _get_value(property: String):
	match(setget_mode):
		SETGET_MODE.PROPERTY: return holder.get(property)
		SETGET_MODE.ACCESSOR:
			var getter = "get_" + property
		
			if !holder.has_method(getter):
				return holder.get(property)
			
			return holder.call(getter)


func _set_value(property: String, value) -> void:
	match(setget_mode):
		SETGET_MODE.PROPERTY: holder.set(property, value)
		SETGET_MODE.ACCESSOR: 
			var setter = "set_" + property
		
			if !holder.has_method(setter):
				holder.set(property, value)
				return
			
			holder.call(setter, value)


func _on_EVENTS_remote_peer_handled_state_received(node_path: String, remote_state: Dictionary) -> void:
	if is_handled_by_client() == NETWORK.is_client():
		return
	
	if node_path == str(get_path()):
		deserialize(remote_state)

