extends Behaviour
class_name ActivableBehaviour

export var active : bool = false setget set_active, is_active 
export(float, 0.0, 999.0, 0.1) var active_change_cooldown : float = 0.0
export var stay_active : bool = false
export var debug : bool = false

# Instead of being activated, toggle the active variable
export var togglable : bool = false

signal active_changed(active)

#### ACCESSORS ####

func is_class(value: String): return value == "ActivableBehaviour" or .is_class(value)
func get_class() -> String: return "ActivableBehaviour"

func set_active(value: bool) -> void:
	if disabled:
		return
	
	if value != active && !$Cooldown.is_running():
		if stay_active && value == false:
			return
		
		active = value
		if debug: print("%s active changed: %s" % [owner.name, str(active)])
		
		if !is_equal_approx(active_change_cooldown, 0.0):
			$Cooldown.start(active_change_cooldown)
		
		emit_signal("active_changed", active)
func is_active() -> bool: return active

func set_active_force(value: bool) -> void:
	if value != active:
		active = value
		
		if !is_equal_approx(active_change_cooldown, 0.0):
			$Cooldown.start(active_change_cooldown)
		
		emit_signal("active_changed", active)


#### BUILT-IN ####

func _ready() -> void:
	pass

#### VIRTUALS ####



#### LOGIC ####

func trigger() -> void:
	if disabled:
		return
	
	if togglable:
		set_active(!active)
	else:
		set_active(true)



#### INPUTS ####



#### SIGNAL RESPONSES ####
