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
	CHARACTER_STATE_ONLINE = 0x08,
}

export(SETGET_MODE) var setget_mode : int = SETGET_MODE.PROPERTY
export(int, FLAGS, "checkpoint", "save", "game state online", "character state online") var fetch_case_flag : int = 0x00

export var persistant := false
export var serialized_properties := PoolStringArray()


func is_class(value: String): return value == "SerializableBehaviour" or .is_class(value)
func get_class() -> String: return "SerializableBehaviour"


func must_fetch(fetch_case: int) -> bool:
	return bool(fetch_case & fetch_case_flag)


func serialize() -> Dictionary:
	if disabled: return {}
	
	var dict = {}
	
	for property in serialized_properties:
		dict[property] = _get_value(property)
	
	return dict


func deserialize(state: Dictionary) -> void:
	if disabled: return
	
	for property in state.keys():
		_set_value(property, state[property])


func _get_value(property: String):
	match(setget_mode):
		SETGET_MODE.PROPERTY: return holder.get(property)
		SETGET_MODE.ACCESSOR:
			var getter = "get_" + property
		
			if !holder.has_method(getter):
				push_error("Cannot fetch property %s: no getter found" % property)
				continue
			
			return holder.call(getter)


func _set_value(property: String, value) -> void:
	match(setget_mode):
		SETGET_MODE.PROPERTY: holder.set(property, value)
		SETGET_MODE.ACCESSOR: 
			var setter = "set_" + property
		
			if !holder.has_method(setter):
				push_error("Cannot apply serialized state property %s: no setter found" % property)
				continue
			
			holder.call(setter, value)
