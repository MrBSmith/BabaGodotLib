extends Object
class_name InputMapper

func is_class(value: String): return value == "InputMapper" or .is_class(value)
func get_class() -> String: return "InputMapper"

signal profile_changed(profile)

enum PROFILES_PRESET{KEYBOARD, CONTROLLER, CUSTOM}
export(PROFILES_PRESET) var default_profile_id

var profiles_array: Array = []
var current_profile_id : int = default_profile_id setget set_current_profile_id, get_current_profile_id

export var print_logs: bool = false

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

func map_input_profile(profile: InputProfile, player_id: int = -1) -> void:
	for action_name in profile.dict.keys():
		if player_id >= 0 && !is_action_of_player(action_name, player_id):
			continue
		
		remap_action_key(action_name, profile.dict[action_name])
	
	EVENTS.emit_signal("input_profile_changed", profile.dict, player_id)


func change_custom_profile_key(action_name: String, input_array: Array = []) -> void:
	var custom_profile = profiles_array[PROFILES_PRESET.CUSTOM]
	if custom_profile.dict.has(action_name):
		profiles_array[PROFILES_PRESET.CUSTOM].dict[action_name] = input_array


func map_current_profile() -> void:
	map_input_profile(get_current_profile())


func get_profile_by_name(profile_name: String) -> InputProfile:
	var profile_id = PROFILES_PRESET.keys().find(profile_name.to_upper())
	
	if profile_id == -1:
		push_error("Given profile name %s not found" % profile_name)
		return null
	
	return profiles_array[profile_id] as InputProfile


func get_player_profile(player_id : int) -> String:
	for i in range(profiles_array.size()):
		var profile = profiles_array[i]
		
		for j in range(profile.dict.keys().size()):
			var action = profile.dict.keys()[j]
			if !is_action_of_player(action, player_id):
				continue
			
			var profile_inputs = profile.dict[action]
			var mapped_inputs = InputMap.get_action_list(action)
			
			if !compare_inputs_list(profile_inputs, mapped_inputs):
				break
			
			return PROFILES_PRESET.keys()[i].capitalize()
	
	return "Custom"



func compare_inputs_list(list_a: Array, list_b: Array) -> bool:
	if list_a.size() != list_b.size():
		return false
	
	for i in range(list_a.size()):
		if list_a[i].as_text() != list_b[i].as_text():
			return false
	
	return true



func is_action_of_player(action_name: String, player_id: int) -> bool:
	return ("player" + str(player_id + 1)).is_subsequence_of(action_name)


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
func fetch_file_inputs(file_path: String) -> Dictionary:
	var cfg_file = ConfigFile.new()
	var err = cfg_file.load(file_path)
	
	if err != OK:
		push_error("Error while opening the .cfg settings file at path %s" % file_path)
		return {}
	
	return cfg_file.get_value("controls", "inputs")


# Fetch all data contained in the default_profile_file located at given path and hydrate profiles_array with it 
func fetch_default_profiles_data(default_profile_file_path: String) -> void:
	profiles_array = _fetch_input_profile_from_file(default_profile_file_path)


# inputs = {
#	player1: {
#		"Controller": {
#			"action": [input_event...],
#			"move_left": [input_event...]
#		}
#	}
#	player2: {
#		"Controller": {
#			"action": [input_event...],
#			"move_left": [input_event...]
#		}
#	}
#	commons: {
#		"cancel": [input_event...]
#	}
# }

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
func map_player_settings_inputs(file_path: String, input_handler: Node) -> void:
	var serialized_inputs = fetch_file_inputs(file_path)
	var inputs_dict = input_handler.deserialize_inputs(serialized_inputs)
	
	input_handler.update_inputs(inputs_dict)


# This function will remove the current keys in the given action from the settings and add a new key instead
func remap_action_key(action_name : String, input_array : Array):
	erase_action_keys(action_name)

	for input in input_array:
		InputMap.action_add_event(action_name, input)
	
	if print_logs: 
		print("action mapped %s with: %s" % [action_name, input_array[0].as_text()])
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
