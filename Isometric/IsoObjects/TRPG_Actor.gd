extends TRPG_DamagableObject
class_name TRPG_Actor

enum ALERATION_TYPE {
	SLEEP,
	POISON,
	FROZEN,
	BURNING,
	DEAD
}

onready var statesmachine = $States
onready var move_node = $States/Move
onready var sfx_node = get_node_or_null("SFX")

export var portrait : Texture
export var timeline_port : Texture
export var MaxStats : Resource
export var default_attack_aoe : Resource = null setget , get_default_attack_aoe
export var default_attack_effect : Resource = null setget , get_default_attack_effect

export var weapon : Resource setget set_weapon, get_weapon
export var skills := Array() setget set_skills, get_skills

var active : bool = false

var items : Array = []
var equipment : Array = []

var current_actions : int = 0 setget set_current_actions, get_current_actions
var current_movements : int = 0 setget set_current_movements, get_current_movements
var current_MP : int = 0 setget set_current_MP, get_current_MP

var default_range : int = 1 setget set_default_range, get_default_range

var action_modifier : int = 0 setget set_action_modifier, get_action_modifier
var jump_max_height : int = 2 setget set_jump_max_height, get_jump_max_height

var move_speed : float = 150.0
var direction : int = IsoLogic.DIRECTION.BOTTOM_RIGHT setget set_direction, get_direction

var view_field : Array = [[], []] setget set_view_field, get_view_field
var path := PoolVector3Array()

signal changed_direction(dir)
signal action_spent
signal turn_finished
signal movement_finished

### ACCESORS ###

func is_class(value: String): return value == "TRPG_Actor" or .is_class(value)
func get_class() -> String: return "TRPG_Actor"

func set_active(value: bool):
	active = value
	if active:
		turn_start()
	else:
		turn_finish()

func get_max_HP(): return MaxStats.get_HP()
func get_max_MP(): return MaxStats.get_MP()

func get_max_actions(): return MaxStats.get_actions()
func get_max_movements(): return MaxStats.get_movements()

func get_current_HP(): return current_HP
func set_current_HP(value : int):
	if value >= 0 && value <= get_max_HP() && value != current_HP:
		current_HP = value
		EVENTS.emit_signal("actor_stats_changed", self)

func get_current_MP(): return current_MP
func set_current_MP(value: int): 
	if value >= 0 && value <= get_max_MP() && value != current_MP:
		current_MP = value
		EVENTS.emit_signal("actor_stats_changed", self)

func set_default_range(value: int): default_range = value
func get_default_range() -> int: return default_range

func get_current_range() -> int: 
	var current_range = get_default_range() if weapon == null else 0
	if !weapon: return current_range
	
	for item in equipment:
		if item.has_method("get_attack_range"):
			current_range += item.get_attack_range()
	return current_range

func set_current_actions(value : int):
	var callback : bool = value < current_actions
	current_actions = value
	if callback:
		emit_signal("action_spent")

func get_current_actions(): return current_actions

func set_current_movements(value : int): current_movements = value
func get_current_movements(): return current_movements

func set_state(value : String): statesmachine.set_state(value)
func get_state() -> Object: return statesmachine.get_state()
func get_state_name() -> String: return statesmachine.get_state_name()

func set_jump_max_height(value : int): jump_max_height = value
func get_jump_max_height() -> int: return jump_max_height

func set_action_modifier(value: int): action_modifier = value
func get_action_modifier() -> int: return action_modifier

func set_weapon(value: Resource): weapon = value
func get_weapon() -> Resource: return weapon

func get_defense() -> int: return MaxStats.get_defense()

func get_view_range() -> int: return MaxStats.get_view_range() + get_altitude() * 2

func set_view_field(value: Array):
	if value != view_field:
		view_field = value
		if self.is_class("Ally"):
			EVENTS.emit_signal("visible_cells_changed")

func get_view_field() -> Array: return view_field
func get_view_field_v3_array() -> PoolVector3Array: return PoolVector3Array(view_field[0] + view_field[1])

func set_direction(value: int):
	if value >= len(IsoLogic.DIRECTION):
		print("The given direction value is outside the DIRECTION enum size | entity name: " + self.name)
		return
	
	if value == direction:
		return
	
	else:
		direction = value
		emit_signal("changed_direction", direction)

func get_direction() -> int: return direction 

func set_skills(array: Array):
	for value in array:
		if not value.is_class("Skill"):
			return
	skills = array

func get_skills() -> Array: return skills

func get_team() -> Node: return get_parent()

func get_attack_aoe() -> Resource:
	if weapon != null:
		var weapon_aoe = weapon.aoe
		if weapon_aoe != null:
			return weapon_aoe
	return default_attack_aoe


func get_default_attack_aoe() -> Resource: return default_attack_aoe

func get_default_attack_effect() -> Resource: return default_attack_effect

#### BUILT-IN ####

# Add the node to the group allies
func _init():
	add_to_group("Actors")


# Set the current stats to the starting stats
func _ready():
	var combat_node = get_tree().get_current_scene()
	var _err = connect("action_spent", combat_node, "on_action_spent")
	_err = statesmachine.connect("state_changed", self, "_on_state_changed")
	
	set_current_actions(get_max_actions())
	set_current_movements(get_max_movements())
	set_current_HP(get_max_HP())
	set_current_MP(get_max_MP())
	update_equipment()


#### CALLBACKS ####

func turn_start():
	set_current_actions(get_max_actions() + action_modifier)
	action_modifier = 0

func turn_finish():
	pass

#### LOGIC ####


func update_equipment():
	equipment = [weapon]


func decrement_current_action(amount : int = 1):
	set_current_actions(get_current_actions() - amount)


func move(move_path: PoolVector3Array) -> void:
	path = move_path
	set_state("Move")
	yield(self, "movement_finished")
	decrement_current_action()


func wait() -> void:
	set_action_modifier(1)
	emit_signal("turn_finished")


func attack(aoe_target: AOE_Target) -> void:
	set_state("Attack")
	apply_combat_effect(default_attack_effect, aoe_target)


func use_item(item: Item, aoe_target: AOE_Target) -> void:
	set_state("Skill")
	apply_combat_effect(item.effect, aoe_target)


func use_skill(skill: Skill, aoe_target: AOE_Target) -> void:
	set_state("Skill")
	apply_combat_effect(skill.effect, aoe_target)


func apply_combat_effect(effect: Effect, aoe_target: AOE_Target) -> void:
	var cells_in_area = map.get_cells_in_area(aoe_target)
	var targets_array = owner.map_node.get_objects_in_area(cells_in_area)

	if targets_array == []:
		return

	# Trigger the attack
	for target in targets_array:
		var damage_array = CombatEffectHandler.compute_damage(effect, self, target)

		for damage in damage_array:
			target.hurt(damage)

		var dir = IsoLogic.get_cell_direction(current_cell, aoe_target.target_cell)
		set_direction(dir)

		if target != self:
			yield(target, "hurt_animation_finished")
	
	decrement_current_action()
	EVENTS.emit_signal("actor_action_animation_finished", self)


# Move the active_actor along the path
func move_along_path(delta: float):
	if path.size() > 0:
		var target_point_world = map.cell_to_world(path[0])
		
		var future_cell = path[1] if path.size() > 1 else current_cell
		var chara_iso_dir = IsoLogic.get_cell_direction(current_cell, future_cell)
		
		var is_moving_bottom = chara_iso_dir in [IsoLogic.DIRECTION.BOTTOM_LEFT, IsoLogic.DIRECTION.BOTTOM_RIGHT]
		
		var char_pos = get_global_position()
		var spd = move_speed * delta
		var velocity = (target_point_world - char_pos).normalized() * spd
		
		# Update actor's current_cell if the actor is moving in a bottom direction 
		# (So the rendering order is correct)
		if !is_moving_bottom:
			var future_pos = char_pos + velocity
			
			if !map.is_world_pos_in_cell(future_pos, get_current_cell()) && path.size() > 0:
				set_current_cell(path[0])
		
		# Move the actor
		if char_pos.distance_to(target_point_world) <= spd:
			set_global_position(target_point_world)
		else:
			set_global_position(char_pos + velocity)
		
		var arrived_to_next_point = target_point_world.is_equal_approx(get_global_position())
		
		# If the actor is arrived to the next point, 
		# remove this point from the path and take the next for destination
		if arrived_to_next_point == true:
			if path.size() > 1:
				set_direction(chara_iso_dir)
				
				# Update actor's current_cell if the actor is moving in a top direction 
				if is_moving_bottom:
					set_current_cell(future_cell)
			
			path.remove(0)
	
	if len(path) == 0:
		set_state("Idle")
		map.update_view_field(self)
		EVENTS.emit_signal("actor_action_animation_finished", self)


func hurt(damage: int):
	set_current_HP(int(clamp(get_current_HP() - damage, 0.0, get_max_HP())))
	EVENTS.emit_signal("damage_inflicted", damage, self)
	set_state("Hurt")


# Return the altitude of the current cell of the character
func get_altitude() -> int:
	return int(current_cell.z)


func set_flip_h_SFX(value: bool):
	if sfx_node == null: return
	
	for child in sfx_node.get_children():
		if child.has_method("set_flip_h"):
			if child.is_flipped_h() != value:
				child.set_flip_h(value)
				child.set_position(child.get_position() * Vector2(-1, 1))



#### SIGNAL RESPONSES ####


func _on_state_changed(_new_state_name: String):
	var previous_state = statesmachine.previous_state
	
	if previous_state != null:
		match(previous_state.name):
			"Hurt": emit_signal("hurt_animation_finished")
			"Move": emit_signal("movement_finished")
