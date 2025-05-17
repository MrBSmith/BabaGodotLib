extends Node
class_name InputsUtils

static func input_find_matching_actions(event: InputEvent) -> Array[String]:
	var matching_actions : Array[String] = []
	
	for action in InputMap.get_actions():
		if InputMap.action_has_event(action, event):
			matching_actions.append(action)
	
	return matching_actions


static func key_find_matching_actions(input_event: InputEvent, action_names : Array = []) -> Array[String]:
	var matching_actions : Array[String] = []
	var actions_array = action_names if !action_names.is_empty() else InputMap.get_actions()
	
	for action in actions_array:
		for event in InputMap.action_get_events(action):
			if event.shortcut_match(input_event):
				matching_actions.append(action)
	
	return matching_actions


static func action_get_keys(action: String) -> Array[String]:
	var input_event_array = InputMap.action_get_events(action)
	var keys_array : Array[String] = []
	
	for event in input_event_array:
		keys_array.append(event.as_text())
	
	return keys_array


static func get_input_event_as_text(event: InputEvent) -> String:
	if event == null:
		return ""
	
	if event is InputEventKey and event.scancode == 0:
		return OS.get_keycode_string(DisplayServer.keyboard_get_keycode_from_physical(event.physical_scancode))
	else:
		return event.as_text()


static func are_event_same_input(event_a: InputEvent, event_b: InputEvent) -> bool:
	if event_a == null or event_b == null:
		return false
	
	if event_a.get_class() != event_b.get_class():
		return false
	
	if event_a is InputEventKey:
		return (event_a.scancode == event_b.scancode and event_a.scancode != 0) \
		or (event_a.physical_scancode == event_b.physical_scancode and event_a.physical_scancode != 0)
	
	elif event_a is InputEventJoypadButton:
		return event_a.button_index == event_b.button_index
	
	elif event_a is InputEventJoypadMotion:
		return event_a.axis == event_b.axis and sign(event_a.axis_value) == sign(event_b.axis_value)
	
	return false
