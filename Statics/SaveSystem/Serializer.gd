extends Node
class_name Serializer

static func serialize_tree(scene_root: Node, fetch_type_flag: int, default_state: Dictionary = {}) -> Dictionary:
	if !is_instance_valid(scene_root):
		push_error("Invalid scene root: abort serializing")
		return {}
	
	var dict = {
		"root_path": scene_root.get_path(),
		"branch_state": {},
		"removed_elements": {},
	}
	
	if fetch_type_flag & SerializableBehaviour.FETCH_CASE_FLAG.GAME_STATE_ONLINE:
		dict["instance_id"] = scene_root.get_instance_id()
	
	var nodes = scene_root.get_tree().get_nodes_in_group("Serializable")
	
	# Fetch curent branch state
	for node in nodes:
		if !scene_root.is_a_parent_of(node):
			continue
		
		var node_path : String = str(scene_root.get_path_to(node))
		var serializable_behav : SerializableBehaviour = Utils.find_behaviour(node, "Serializable")
		
		if !serializable_behav:
			push_error("Cannot serialize node at path: %s :Couldn't find serializable behaviour" % node_path)
			continue
		
		if !serializable_behav.must_fetch(fetch_type_flag):
			continue
		
		var properties : Dictionary = serializable_behav.serialize()
		
		dict["branch_state"][node_path] = properties 
	
	# Find removed elements
	if default_state.has("branch_state"):
		for node_path in default_state["branch_state"].keys():
			if !dict["branch_state"].has(node_path):
				dict["removed_elements"][node_path] = {}
	
	return dict


static func deserialize_tree(scene_root: Node, dict: Dictionary, fetch_type_flag: int = SerializableBehaviour.FETCH_CASE_FLAG.SAVE) -> void:
	if !dict.has("root_path") or !dict.has("branch_state"):
		push_error("Invalid data format: abort deserializing")
		return
	
	if !is_instance_valid(scene_root) or scene_root.get_path() != dict["root_path"]:
		push_error("Invalid scene root: abort deserializing")
		return
	
	var fetch_online = fetch_type_flag & SerializableBehaviour.FETCH_CASE_FLAG.GAME_STATE_ONLINE
	
	if fetch_online:
		var remote_id_behav = Utils.find_behaviour(scene_root, "RemoteInstanceId")
		
		if remote_id_behav and remote_id_behav.remote_instance_id != dict["instance_id"]:
			push_error("Cannot apply the branch state: invalid instance id")
			return
	
	var nodes = scene_root.get_tree().get_nodes_in_group("Serializable")
	
	for node in nodes:
		if !scene_root.is_a_parent_of(node):
			continue
		
		var node_path : String = str(scene_root.get_path_to(node))
		var serializable_behav = Utils.find_behaviour(node, "Serializable")
		
		if !serializable_behav:
			push_error("Cannot serialize node at path: %s :Couldn't find serializable behaviour" % node_path)
			continue
		
		if fetch_online and NETWORK.is_online() and !serializable_behav.must_apply(fetch_type_flag):
			continue
		
		if node_path in dict["removed_elements"].keys():
			if serializable_behav.persistant_flag & fetch_type_flag:
				node.queue_free()
			else:
				push_error("Node at path %s is not persistant but doesn't appear in the serialized state" % node_path)
		else:
			if dict["branch_state"].has(node_path):
				serializable_behav.deserialize(dict["branch_state"][node_path])


# Compare two state dicts: if both have the same key but with different values, a will preveil over b
static func state_diff(a: Dictionary, b: Dictionary) -> Dictionary:
	if b.empty() or a["root_path"] != b["root_path"] or a["instance_id"] != b["instance_id"]:
		return a
	
	var diff = {
		"root_path": a["root_path"],
		"instance_id": a["instance_id"],
		"branch_state": {},
		"removed_elements": {},
	}
	
	var states = [a, b] 
	
	for dict_key in ["branch_state", "removed_elements"]:
		diff[dict_key] = dict_diff(a[dict_key], b[dict_key])
	
	return diff


static func dict_diff(a: Dictionary, b: Dictionary) -> Dictionary:
	var diff = {}
	var states = [a, b]
	var treated_keys = []
	
	for i in states.size():
		var current = states[i]
		var other = states[i - 1]
		
		for key in current:
			if key in treated_keys:
				continue
			
			if !other.has(key) or !are_property_dict_equal(current[key], other[key]):
				diff[key] = current[key]
				treated_keys.append(key)
	
	return diff


static func are_property_dict_equal(a: Dictionary, b: Dictionary) -> bool:
	for key in a.keys():
		if !b.has(key):
			return false
		
		if str(a[key]) != str(b[key]):
			return false
	return true

