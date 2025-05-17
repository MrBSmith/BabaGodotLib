extends Trait
class_name ActivableTrait

@onready var cooldown : Timer = $Cooldown

@export var active : bool = false:
	set(value):
		if value != active and (cooldown.is_stopped() or cooldown.is_paused()):
			if stay_active and value == false:
				return
			
			active = value
			
			if !is_equal_approx(active_change_cooldown, 0.0):
				cooldown.start(active_change_cooldown)
			
			active_changed.emit(active)

@export_range(0.0, 999.0, 0.1) var active_change_cooldown : float = 0.0
@export var stay_active : bool = false
@export var togglable : bool = false

signal active_changed(active)

func set_active_force(value: bool) -> void:
	if value != active:
		active = value
		
		if !is_equal_approx(active_change_cooldown, 0.0):
			cooldown.start(active_change_cooldown)
		
		active_changed.emit(active)

func trigger() -> void:
	if togglable:
		toggle()
	else:
		active = true


func toggle() -> void:
	active = !active
