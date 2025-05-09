extends Behaviour
class_name DestructibleBehaviour

# This Behaviour makes its parent destructible
# The destructible object can be damaged using the damage method
# when its hp reachs zero, the destroy method will be called

# If it has a DestroySound child (should be a AudioStreamPlayer or a AudioStreamPlayer2D)
# a play_sound_effect event will be called when the destroy method is called

# If it has a Particles2D child (should be a Particles2D)
# a play_particule_FX event will be called when the destroy method is called

# Then the destroy_animation_started signal will be called (before the animation starts)
# If it has a AnimationPlayer and it has a Destroy animation, this animation will be launched
# then the destroyed signal is called when the animation is over


enum FREE_AFTER {
	NONE,
	ANIMATION,
	PARTICLES,
}


onready var animation_player = get_node_or_null("AnimationPlayer")
onready var damage_computer = get_node_or_null("DamageComputer")
onready var destroy_sound = get_node_or_null("DestroySound")
onready var approch_area = get_node_or_null("ApprochArea")
onready var particules = get_node_or_null("Particles2D")
onready var serializable_behaviour = get_node_or_null(serializable_behaviour_path)

export(int, 1, 9999) var max_hp : int = 1 setget set_max_hp
export var hp : int = max_hp setget set_hp, get_hp

export var serializable_behaviour_path := NodePath()
export var free_when_destroyed := true
export var undommagable : bool = false
export var invincible : bool = false
export var cooldown : float = INF setget set_cooldown
export var distant_confirmation := false

export(FREE_AFTER) var free_after_mode = FREE_AFTER.ANIMATION

var is_destroyed := false

signal max_hp_changed(max_hp_value)
signal hp_changed(hp_value)
#warning-ignore:unused_signal
signal destroy_animation_started()
signal damaged()
signal pre_destroyed()
signal destroyed()
#warning-ignore:unused_signal
signal destruction_confirmed()
signal destruction_aborted()

#### ACCESSORS ####

func is_class(value: String): return value == "DestructibleBehaviour" or .is_class(value)
func get_class() -> String: return "DestructibleBehaviour"

func set_max_hp(value: int) -> void:
	if value != max_hp:
		if value < 0:
			push_error("The given max_hp %d isn't valid. The max hp value can't be less than 0" % value)
			return
		
		max_hp = value
		emit_signal("max_hp_changed", max_hp)

func set_hp(value: int) -> void:
	if value != hp:
		hp = value
		emit_signal("hp_changed", hp)
func get_hp() -> int: return hp 


func set_cooldown(value: float) -> void:
	value = clamp(value, 0.0001, INF)
	$Cooldown.wait_time = value


#### BUILT-IN ####

func _ready() -> void:
	var __ = connect("hp_changed", self, "_on_hp_changed")
	if approch_area:
		__ = approch_area.connect("body_entered", self, "_on_body_entered")
	
	owner.add_to_group("Destructible")


#### VIRTUALS ####



#### LOGIC ####

func restore() -> void:
	is_destroyed = false
	set_hp(max_hp)


func damage() -> void:
	if $Cooldown.is_running():
		return
	
	if !undommagable:
		if damage_computer:
			set_hp(Math.clampi(hp - damage_computer.compute_damage(), 0, max_hp))
		else:
			set_hp(Math.clampi(hp - 1, 0, max_hp))
	
	emit_signal("damaged")
	
	if $Cooldown.wait_time != INF:
		$Cooldown.start()


func destroy_with_confirmation() -> void:
	if !NETWORK.is_online():
		destroy()
		return
	
	if !serializable_behaviour._is_handler_peer():
		return
	
	destroy()
	NETWORK.remote_call_both_way(self, "distant_destroy_attempt")


func distant_destroy_attempt() -> void:
	if serializable_behaviour._is_handler_peer():
		NETWORK.remote_call_both_way(self, "emit_signal", ["destruction_aborted"])
	else:
		NETWORK.remote_call_both_way(self, "emit_signal", ["destruction_confirmed"])
		NETWORK.call_and_remote_call_both_way(self, "destroy")


func destroy() -> void:
	if invincible or is_destroyed:
		return
	
	is_destroyed = true
	
	if destroy_sound:
		EVENTS.emit_signal("play_sound_effect_by_path", destroy_sound.get_path())
	
	if particules:
		particules.set_emitting(true)
	
	emit_signal("destroy_animation_started")
	
	if animation_player && animation_player.has_animation("Destroy"):
		animation_player.play("Destroy")
	
	match(free_after_mode):
		FREE_AFTER.PARTICLES: 
			if particules: 
				var __ = get_tree().create_timer(particules.lifetime).connect("timeout", self, "fire_destroy_signals")
				return
		FREE_AFTER.ANIMATION: 
			if animation_player: 
				var __ = animation_player.connect("animation_finished", self, "fire_destroy_signals")
				return
	
	fire_destroy_signals()


func fire_destroy_signals() -> void:
	if !is_destroyed:
		return
	
	emit_signal("pre_destroyed")
	emit_signal("destroyed")
	
	if free_when_destroyed:
		owner.call_deferred("queue_free")




#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_hp_changed(hp_value: int) -> void:
	if animation_player && animation_player.has_animation("Damage"):
		animation_player.play("Damage")
	
	if hp_value <= 0 and !invincible:
		destroy()

