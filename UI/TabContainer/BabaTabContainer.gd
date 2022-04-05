extends TabContainer
class_name BabaTabContainer

var frozen : bool = false setget set_frozen, is_frozen

signal frozen_changed(value)

#### ACCESSORS ####

func is_class(value: String): return value == "BabaTabContainer" or .is_class(value)
func get_class() -> String: return "BabaTabContainer"

func set_frozen(value: bool) -> void:
	if value != frozen:
		frozen = value
		emit_signal("frozen_changed", frozen)
func is_frozen() -> bool: return frozen


#### BUILT-IN ####

func _ready() -> void:
	var __ = connect("frozen_changed", self, "_on_frozen_changed")


#### VIRTUALS ####



#### LOGIC ####

func _is_focus_free() -> bool:
	var control_focused = owner.get_focus_owner()
	return control_focused == null or control_focused == self or control_focused in get_children() or \
				(control_focused is MenuOptionsBase and !control_focused.is_focused())


#### INPUTS ####

func _input(_event: InputEvent) -> void:
	if frozen:
		return
	
	if Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_left"):
		if _is_focus_free():
			var tab_id = get_current_tab()
			var neighbour_dir = 1 if Input.is_action_just_pressed("ui_right") else -1
			var next_tab_id = wrapi(tab_id + neighbour_dir, 0, get_tab_count())
			
			set_current_tab(next_tab_id)



#### SIGNAL RESPONSES ####

func _on_frozen_changed(_value: bool) -> void:
	for i in range(get_tab_count()):
		set_tab_disabled(i, frozen)
