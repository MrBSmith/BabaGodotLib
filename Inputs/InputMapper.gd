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
	for action_name in profile.dict.keys():
		remap_action_key(action_name, profile.dict[action_name])
	
	EVENTS.emit_signal("input_profile_changed", profile.dict)


func change_custom_profile_key(action_name: String, input_array: Array = []) -> void:
	var custom_profile = profiles_array[PROFILES_PRESET.CUSTOM]
	if custom_profile.dict.has(action_name):
		profiles_array[PROFILES_PRESET.CUSTOM].dict[action_name] = input_array


func map_current_profile() -> void:
	map_input_profile(get_current_profile())


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
		var input_array = []
		
		for input_event in input_event_array:
			input_array.append(input_event)
		
		actions_dict[action] = input_array
	
	return actions_dict


# Fetch all data contained in the default_profile_file located at given path and hydrate profiles_array with it 
func fetch_default_profiles_data(default_profile_file_path: String) -> void:
	profiles_array = _fetch_input_profile_from_file(default_profile_file_path)


# Fetch input relative data form the file at the given path located in the given sections and returns an array of profiles found
# Each section have to correspond to a profile, if sections_to_read is empty, each sections of the file will be considered a profile
func _fetch_input_profile_from_file(file_path: String, sections_to_read : Array = []) -> Array:
	var input_profile_config_file = ConfigFile.new()
	var err = input_profile_config_file.load(file_path)
	
	if sections_to_read.empty():
		sections_to_read = input_profile_config_file.get_sections()
	
	if err == OK:
		var input_profile_array = []
		
		for section_name in sections_to_read:
			var dict = Dictionary()
			for key in input_profile_config_file.get_section_keys(section_name):
				dict[key] = input_profile_config_file.get_value(section_name, key)
			
			var is_custom_profile = section_name == "custom"
			input_profile_array.append(InputProfile.new(dict, is_custom_profile))
		
		return input_profile_array 
		
	else:
		push_error("Failed to load input profile config file. Error code : " + str(err))
		return []


# Fetch the player's default_profile file content, then map the profile fetched
func map_player_default_profile(players_settings_file_path: String, sections: Array = []) -> void:
	var profile_array = _fetch_input_profile_from_file(players_settings_file_path, sections)
	var players_input_profile = null 
	
	# Default input
	if profile_array.size() == 3:
		 players_input_profile = profile_array[PROFILES_PRESET.QWERTY]
	
	# Players input
	elif profile_array.size() == 1:
		 players_input_profile = profile_array[0]
	
	if players_input_profile == null:
		push_error("The player's input profile couldn't be fetched in the file located: %s" % players_settings_file_path)
		return
	
	map_input_profile(players_input_profile)


# This function will remove the current keys in the given action from the settings and add a new key instead
func remap_action_key(action_name : String, input_array : Array):
	erase_action_keys(action_name)

	for input in input_array:
		InputMap.action_add_event(action_name, input)
	
	EVENTS.emit_signal("input_mapped", action_name, input_array)


# This function will remove the selected action from the settings (InputMap)
func erase_action_keys(action_name: String):
	var input_events = InputMap.get_action_list(action_name)
	for event in input_events:
		InputMap.action_erase_event(action_name, event)



#### INPUT ####


#### SIGNALS RESPONSES ####

func _on_profile_selected(id: int):
	set_current_profile_id(id)
