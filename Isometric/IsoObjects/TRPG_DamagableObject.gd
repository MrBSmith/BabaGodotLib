extends IsoObject
class_name TRPG_DamagableObject

onready var sprite_node = get_node_or_null("Sprite")
onready var animated_sprite_node = get_node_or_null("AnimatedSprite")
onready var animation_player_node = get_node_or_null("AnimationPlayer")
onready var lifebar_scene = load(lifebar_scene_path)

export var lifebar_scene_path = "res://Scenes/Actors/Gauge/DamagableSmallGauge.tscn"
export var defense : int = 0 setget set_defense, get_defense

export var max_HP : int = 0 setget set_max_HP, get_max_HP
export var current_HP : int = -1 setget set_current_HP, get_current_HP

var lifebar : Control
var clickable_area : Area2D
var mouse_inside : bool = false

signal action_consequence_finished
signal hp_changed

#### ACCESSORS ####

func is_class(value: String): return value == "TRPG_DamagableObject" or .is_class(value)
func get_class() -> String: return "TRPG_DamagableObject"

# Must be overriden
func is_dead() -> bool: return false

func set_current_HP(value: int):
	if value >= 0 && value <= get_max_HP() && value != current_HP:
		current_HP = value
		if !is_ready:
			yield(self, "ready")
		emit_signal("hp_changed", get_current_HP(), get_max_HP())
func get_current_HP() -> int: return current_HP

func set_max_HP(value: int):
	max_HP = value
	if !is_ready:
		yield(self, "ready")
	emit_signal("hp_changed", get_current_HP(), get_max_HP())
func get_max_HP() -> int: return max_HP

func set_defense(value: int):
	defense = value
func get_defense() -> int:
	return defense

func set_visibility(value: int):
	.set_visibility(value)
	if self.name == "Crate":
		pass


#### BUILT-IN FUNCTIONS ####

func _ready() -> void:
	yield(owner, "ready")
	
	var _err = EVENTS.connect("unfocus_all_iso_object_query", self, "_on_unfocus_all_iso_object_query")
	if !self.is_class("TRPG_Actor"):
		_err = $AnimationPlayer.connect("animation_finished", self, "_on_hurt_feedback_finished")
	_err = connect("destroy_animation_finished", self, "_on_destroy_animation_finished")
	
	if current_HP == -1: set_current_HP(get_max_HP())
	
	generate_lifebar()
	generate_clickable_area()


#### LOGIC ####

func generate_lifebar() -> void:
	lifebar = lifebar_scene.instance()
	var y_offset = (get_height() + 1) * GAME.TILE_SIZE.y
	lifebar.set_position(Vector2(0, -y_offset - 5))
	lifebar.shake_feedback_on = true
	lifebar.set_visible(false)
	add_child(lifebar)
	
	lifebar.set_gauge_max_value(get_max_HP())
	lifebar.set_gauge_value(get_current_HP())
	var __ = connect("hp_changed", lifebar, "_on_damagable_hp_changed")


func get_sprite_texture(sprite: Node2D) -> Texture:
	if sprite == null:
		return null
	
	if sprite is Sprite:
		return sprite.get_texture()
	else :
		var animation = sprite.get_animation()
		var current_frame = sprite.get_frame()
		var sprite_frames = sprite.get_sprite_frames()
		return sprite_frames.get_frame(animation, current_frame)


# Generate the area that will detect the mouse going over the sprite
func generate_clickable_area() -> void:
	clickable_area = Area2D.new()
	add_child(clickable_area)
	clickable_area.owner = self

	var collision_shape = CollisionShape2D.new()
	
	var rect_shape = RectangleShape2D.new()
	rect_shape.set_extents((height * GAME.TILE_SIZE) / 2)
	
	collision_shape.set_shape(rect_shape)
	clickable_area.add_child(collision_shape)

	var _err = clickable_area.connect("mouse_entered", self, "_on_mouse_entered")
	_err = clickable_area.connect("mouse_exited", self, "_on_mouse_exited")


# Show the known actors infos
func show_infos() -> void:
	lifebar.update()
	lifebar.set_visible(true)
	EVENTS.emit_signal("iso_object_focused", self)

# Hide the infos 
func hide_infos() -> void:
	lifebar.set_visible(false)
	EVENTS.emit_signal("iso_object_unfocused", self)


func hurt(damage: int) -> void:
	set_current_HP(Math.clampi(get_current_HP() - damage, 0, get_max_HP()))
	EVENTS.emit_signal("damage_inflicted", damage, self)
	
	if has_method("set_state"):
		call("set_state", "Hurt")
	else:
		$AnimationPlayer.play("RedFlash")


# Function override
func destroy() -> void:
	EVENTS.emit_signal("iso_object_unfocused", self)
	emit_signal("action_consequence_finished")
	trigger_destroy_animation()


func trigger_destroy_animation() -> void:
	EVENTS.emit_signal("scatter_object", self, 16)
	emit_signal("destroy_animation_finished")


#### SIGNAL RESPONSES ####

func _on_mouse_entered() -> void:
	mouse_inside = true
	if self != owner.active_actor && is_in_view_field() && !is_dead():
		show_infos()


func _on_mouse_exited() -> void:
	mouse_inside = false
	if not self == owner.active_actor:
		hide_infos()


func _on_unfocus_all_iso_object_query() -> void:
	hide_infos()


func _on_hurt_feedback_finished() -> void:
	if get_current_HP() <= 0:
		destroy()
	else:
		emit_signal("action_consequence_finished")


func _on_destroy_animation_finished() -> void:
	queue_free()
