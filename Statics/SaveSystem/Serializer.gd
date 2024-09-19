extends Node
class_name Serializer

static func serialize_tree(scene_root: Node, fetch_type_flag: int) -> Dictionary:
	if !is_instance_valid(scene_root):
		push_error("Invalid scene root: abort serializing")
		return {}
	
	var dict = {
		"root_path": scene_root.get_path(),
		"branch_state" : {},
	}
	var nodes = scene_root.get_tree().get_nodes_in_group("Serializable")
	
	for node in nodes:
		var node_path : String = str(scene_root.get_path_to(node))
		var serializable_behav : SerializableBehaviour = Utils.find_behaviour(node, "Serializable")
		
		if !serializable_behav:
			push_error("Cannot serialize node at path: %s :Couldn't find serializable behaviour" % node_path)
			continue
		
		if !serializable_behav.must_fetch(fetch_type_flag):
			continue
		
		var properties : Dictionary = serializable_behav.serialize()
		
		dict["branch_state"][node_path] = properties 
	
	return dict


static func deserialize_tree(scene_root: Node, dict: Dictionary, fetch_type_flag: int = SerializableBehaviour.FETCH_CASE_FLAG.SAVE) -> void:
	if !dict.has("root_path") or !dict.has("branch_state"):
		push_error("Invalid data format: abort deserializing")
		return
	
	if !is_instance_valid(scene_root) or scene_root.get_path() != dict["root_path"]:
		push_error("Invalid scene root: abort deserializing")
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
		
		if !serializable_behav.must_apply(fetch_type_flag):
			continue
		
		if not node_path in dict["branch_state"].keys():
			if serializable_behav.persistant:
				node.queue_free()
			else:
				push_error("Node at path %s is not peristant but doesn't appear in the serialized state" % node_path)
		else:
			serializable_behav.deserialize(dict["branch_state"][node_path])
