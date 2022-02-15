extends TRPG_DamagableObject
class_name TRPG_Actor

onready var statemachine = $States
onready var move_node = $States/Move
onready var sfx_node = get_node_or_null("SFX")

export var portrait : Texture
export var MaxStats : Resource
export var default_attack_effect : Resource
export var default_attack_aoe : Resource setget , get_default_attack_aoe

var active : bool = false

export var weapon : Resource setget set_weapon, get_weapon
export var skills := Array() setget set_skills, get_skills

var ailments : Array = []

export var items : Array = [] setget , get_items
export var equipment : Array = []

export var current_actions : int = -1 setget set_current_actions, get_current_actions
export var current_movements : int = -1 setget set_current_movements, get_current_movements
export var current_MP : int = -1 setget set_current_MP, get_current_MP

var default_range : int = 1 setget set_default_range, get_default_range

var action_modifier : int = 0 setget set_action_modifier, get_action_modifier
var jump_max_height : int = 2 setget set_jump_max_height, get_jump_max_height

var move_speed : float = 150.0
var direction : int = IsoLogic.DIRECTION.BOTTOM_RIGHT setget set_direction, get_direction

var view_field : Array = [[], []] setget set_view_field, get_view_field
var path := PoolVector3Array()

signal state_changed(state)
signal changed_direction(dir)
signal action_spent()
signal action_finished(action_name)
#warning-ignore:unused_signal
signal hit()

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
		.set_current_HP(value)
		EVENTS.emit_signal("actor_stats_changed", self)

func get_current_MP(): return current_MP
func set_current_MP(value: int): 
	if value >= 0 && value <= get_max_MP() && value != current_MP:
		current_MP = value
		EVENTS.emit_signal("actor_stats_changed", self)

func set_default_range(value: int): default_range = value
func get_default_range() -> int: return default_range

func get_current_range() -> int: 
	var current_range = get_default_range() if weapon == null else weapon.aoe.range_size
	return current_range

func set_current_actions(value : int):
	var callback : bool = value < current_actions
	current_actions = value
	if callback:
		emit_signal("action_spent")
func get_current_actions(): return current_actions

func set_current_movements(value : int): current_movements = value
func get_current_movements(): return current_movements

func set_state(value : String): statemachine.set_state(value)
func get_state() -> Object: return statemachine.get_state()
func get_state_name() -> String: return statemachine.get_state_name()

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
		if is_team_side(0):
			EVENTS.emit_signal("visible_cells_changed", self)
func get_view_field() -> Array: return view_field
func get_view_field_v3_array() -> PoolVector3Array: return PoolVector3Array(view_field[0] + view_field[1])

func set_direction(value: int):
	if value >= len(IsoLogic.DIRECTION):
		print("The given direction value is outside the DIRECTION enum size | entity name: " + self.name)
		return
	
	if value == direction: 
		return
	
	direction = value
	emit_signal("changed_direction", direction)
func get_direction() -> int: return direction 

func set_skills(array: Array):
	for value in array:
		if not value.is_class("Skill"):
			return
	skills = array
func get_skills() -> Array: return skills

func get_items() -> Array: return items

func get_team() -> Node: 
	var parent = get_parent()
	if parent.is_class("ActorTeam"):
		return parent
	else:
		return null

func get_combat_state() -> ActorCombatState:
	return ActorCombatState.new(get_current_HP(),
								get_max_HP(),
								get_current_MP(),
								get_max_MP(),
								ailments)

func get_team_side():
	var team = get_team()
	if team != null:
		return team.get_team_side()
	else:
		return -1
func is_team_side(value: int) -> bool:
	var team = get_team()
	if team != null:
		return team.is_team_side(value)
	else:
		return false

func get_default_attack_aoe() -> Resource: return default_attack_aoe

func get_attack_aoe() -> Resource:
	if weapon != null && weapon.aoe != null:
		return weapon.aoe
	else:
		return get_default_attack_aoe()

func get_current_attack_effect() -> Resource:
	if weapon != null && weapon.attack_effect != null:
		return weapon.attack_effect
	else:
		return default_attack_effect

func get_current_attack_combat_effect_object() -> CombatEffectObject:
	return weapon.get_combat_effect_object()

func get_idle_bottom_texture() -> Texture:
	var sprite_frames = animated_sprite_node.get_sprite_frames()
	var atlas_texture = sprite_frames.get_frame("IdleBottom", 0)
	var atlas_image = atlas_texture.get_atlas().get_data()
	var image = Image.new()
	var region_size = atlas_texture.region.size
	
	image.create(region_size.x, region_size.y, false, Image.FORMAT_RGBA8)
	image.blit_rect(atlas_image, atlas_texture.region, Vector2.ZERO)
	image = Utils.trim_image(image)

	var image_texture = ImageTexture.new()
	image_texture.create_from_image(image, 2)
	
	return image_texture


# Function override
func is_dead() -> bool: return get_state() == $States/Death


#### BUILT-IN ####

# Add the node to the group allies
func _init():
	add_to_group("Actors")


# Set the current stats to the starting stats
func _ready():
	var _err = connect("cell_changed", self, "_on_cell_changed")
	_err = connect("action_finished", self, "_on_action_finished")
	_err = statemachine.connect("state_changed", self, "_on_state_changed")
	_err = $States/Hurt.connect("hurt_feedback_finished", self, "_on_hurt_feedback_finished")
	
	if current_actions == -1: set_current_actions(get_max_actions())
	if current_movements == -1: set_current_movements(get_max_movements())
	if current_MP == -1: set_current_MP(get_max_MP())
	update_equipment()


#### CALLBACKS ####

func turn_start():
	set_current_actions(get_max_actions() + action_modifier)
	action_modifier = 0
	
	EVENTS.emit_signal("active_actor_turn_started", self)

func turn_finish():
	pass


#### LOGIC ####


func update_equipment() -> void:
	equipment = [weapon]


func decrement_current_action(amount : int = 1):
	set_current_actions(get_current_actions() - amount)


func move(move_path: PoolVector3Array) -> void:
	path = move_path
	set_state("Move")
	decrement_current_action()


func wait() -> void:
	set_action_modifier(1)


func attack(aoe_target: AOE_Target) -> void:
	set_state("Attack")
	apply_combat_effect(get_current_attack_effect(), aoe_target)


func use_item(item: Item, aoe_target: AOE_Target) -> void:
	set_state("Item")
	apply_combat_effect(item.effect, aoe_target)


func use_skill(skill: Skill, aoe_target: AOE_Target) -> void:
	set_state("Skill")
	apply_combat_effect(skill.effect, aoe_target)


func apply_combat_effect(effect: Effect, aoe_target: AOE_Target, action_spent: int = 1) -> void:
	decrement_current_action(action_spent)
	var cells_in_area = map.get_cells_in_area(aoe_target)
	var targets_array = owner.map_node.get_objects_in_area(cells_in_area)

	if targets_array == []:
		return
	
	EVENTS.emit_signal("damagable_targeted", targets_array)
	
	var dir = IsoLogic.get_cell_direction(current_cell, aoe_target.target_cell)
	set_direction(dir)
	
	# Trigger the attack
	for i in range(effect.nb_hits):
		yield(self, "hit")
		for target in targets_array:
			var damage_array = CombatEffectHandler.compute_damage(effect, self, target)
			
			target.hurt(damage_array[i])


# Move the active_actor along the path
func move_along_path(delta: float):
	if path.size() > 0:
		var target_point_world = map.cell_to_world(path[0])
		
		var future_cell = path[1] if path.size() > 1 else current_cell
		
		var char_pos = get_global_position()
		var spd = move_speed * delta
		var velocity = (target_point_world - char_pos).normalized() * spd
		
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
				var chara_iso_dir = IsoLogic.get_cell_direction(current_cell, future_cell)
				set_direction(chara_iso_dir)
				set_current_cell(future_cell)
			
			path.remove(0)
	
	return len(path) == 0


# Function override
func destroy() -> void:
	EVENTS.emit_signal("actor_died", self)
	.destroy()


func trigger_destroy_animation():
	set_state("Death")


func can_see(obj: IsoObject) -> bool:
	if !owner.fog_of_war:
		return true
	
	var obj_cell = obj.get_current_cell()
	return can_see_cell(obj_cell)


func can_see_cell(cell: Vector3) -> bool:
	return !owner.fog_of_war or cell in view_field[0] or cell in view_field[1]


# Return the altitude of the current cell of the character
func get_altitude() -> int:
	return int(current_cell.z)


func set_flip_h_SFX(value: bool) -> void:
	if sfx_node == null: return
	
	for child in sfx_node.get_children():
		if child.has_method("set_flip_h"):
			if child.is_flipped_h() != value:
				child.set_flip_h(value)
				child.set_position(child.get_position() * Vector2(-1, 1))


#### SIGNAL RESPONSES ####

func _on_state_changed(new_state: Object) -> void:
	emit_signal("state_changed", new_state)
	
	var previous_state = statemachine.previous_state
	
	if previous_state != null:
		if active:
			if previous_state.name in ["Attack", "Move", "Skill"]:
				emit_signal("action_finished", previous_state.name)
		
		if previous_state.name == "Hurt":
			emit_signal("action_consequence_finished")


func _on_action_finished(_action_name: String) -> void:
	pass


func _on_cell_changed(from: Vector3, to: Vector3) -> void:
	EVENTS.emit_signal("actor_cell_changed", self, from, to)


# Function override
func _on_hurt_flash_finished() -> void:
	pass

# Function override
func _on_destroy_animation_finished() -> void:
	pass

# Function override
func _on_hurt_feedback_finished() -> void:
	if get_current_HP() <= 0:
		destroy()
