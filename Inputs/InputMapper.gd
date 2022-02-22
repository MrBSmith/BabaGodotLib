extends Object
class_name InputMapper

func is_class(value: String): return value == "InputMapper" or .is_class(value)
func get_class() -> String: return "InputMapper"

signal profile_changed(profile)

enum PROFILES_PRESET{AZERTY, QWERTY, CUSTOM}
export(PROFILES_PRESET) var default_profile_id

var profiles_array: Array = []
var current_profile_id : int = default_profile_id setget set_current_profile_id, get_current_profile_id


#### ACCESSORS ####

func get_selected_profile() -> Dictionary: return profiles_array[current_profile_id]
func get_profile(id: int) -> Dictionary: return profiles_array[id]

func get_current_profile_id() -> int : return current_profile_id
func set_current_profile_id(value: int) -> void: 
	current_profile_id = value
	
	var profile = get_profile(current_profile_id)
	emit_signal('profile_changed', profile)

func get_current_profile() -> InputProfile: return profiles_array[current_profile_id]


#### BUILT-IN ####



#### LOGIC ####

func map_input_profile(profile: InputProfile) -> void:
	for action_name in profile.keys():
		remap_action_key(action_name, profile[action_name])


func change_custom_profile_key(action_name: String, key_array : Array = []) -> void:
	var custom_profile = profiles_array[PROFILES_PRESET.CUSTOM]
	if custom_profile.dict.has(action_name):
		profiles_array[PROFILES_PRESET.CUSTOM].dict[action_name] = key_array


func map_current_profile() -> void:
	var profile = get_current_profile().dict
	for action_name in profile.keys():
		remap_action_key(action_name, profile[action_name])
	
	if get_current_profile_id() == PROFILES_PRESET.CUSTOM:
		EVENTS.emit_signal("save_custom_input_profile", profile)


# Takes a Dictionary of actions, and check if it matches one of the profiles contained in the profiles_array
# If it does returns its id, if it doesn't returns -1
func find_corresponding_profile(action_dict: Dictionary) -> int:
	for i in range(profiles_array.size()):
		var profile = profiles_array[i]
		if action_dict.hash() == profile.dict.hash():
			return i
	
	return -1


# Fetch every actions contained in actions_to_fetch
# If the action_to_fetch array is empty: fetch every actions
func fetch_current_actions(actions_to_fetch := PoolStringArray()) -> Dictionary:
	var actions_dict = Dictionary()
	
	if actions_to_fetch.empty():
		actions_to_fetch = InputMap.get_actions()
	
	for action in actions_to_fetch:
		var input_event_array = InputMap.get_action_list(action)
		var keys_array = []
		
		for input_event in input_event_array:
			if input_event is InputEventJoypadButton:
				continue
			
			keys_array.append(input_event.scancode)
		
		actions_dict[action] = keys_array
	
	return actions_dict


# Fetch all data contained in the default_profile_file located at given path and hydrate profiles_array with it 
func fetch_default_profiles_data(default_profile_file_path: String) -> void:
	var input_profile_config_file = ConfigFile.new()
	var err = input_profile_config_file.load(default_profile_file_path)
	
	if err == OK:
		for section_name in input_profile_config_file.get_sections():
			var dict = Dictionary()
			for key in input_profile_config_file.get_section_keys(section_name):
				dict[key] = input_profile_config_file.get_value(section_name, key)
			
			var is_custom_profile = section_name == "custom"
			profiles_array.append(InputProfile.new(dict, is_custom_profile))
	else:
		push_error("Failed to load input profile config file. Error code : " + str(err))
		return
	return


# This function will remove the current keys in the given action from the settings and add a new key instead
func remap_action_key(action_name : String, keys_array : Array):
	erase_action_keys(action_name)

	for key in keys_array:
		var new_event = InputEventKey.new()
		new_event.set_scancode(key)
		InputMap.action_add_event(action_name, new_event)


# This function will remove the selected action from the settings (InputMap)
func erase_action_keys(action_name: String):
	var input_events = InputMap.get_action_list(action_name)
	for event in input_events:
		InputMap.action_erase_event(action_name, event)



#### INPUT ####


#### SIGNALS RESPONSES ####

func _on_profile_selected(id: int):
	set_current_profile_id(id)
