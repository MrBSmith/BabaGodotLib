extends IsoObject
class_name TRPG_DamagableObject

onready var sprite_node = get_node_or_null("Sprite")
onready var animated_sprite_node = get_node_or_null("AnimatedSprite")
onready var animation_player_node = get_node_or_null("AnimationPlayer")
onready var lifebar_scene = load(lifebar_scene_path)

export var lifebar_scene_path = "res://Scenes/Actors/Gauge/DamagableSmallGauge.tscn"
export var defense : int = 0 setget set_defense, get_defense

export var max_HP : int = 0 setget set_max_HP, get_max_HP
var current_HP : int = 0 setget set_current_HP, get_current_HP

var lifebar : Control
var clickable_area : Area2D
var mouse_inside : bool = false

signal hurt_animation_finished
signal hp_changed

#### ACCESSORS ####

func is_class(value: String): return value == "TRPG_DamagableObject" or .is_class(value)
func get_class() -> String: return "TRPG_DamagableObject"

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

func _ready():
	yield(owner, "ready")
	
	var _err = EVENTS.connect("unfocus_all_iso_object_query", self, "_on_unfocus_all_iso_object_query")
	
	set_current_HP(get_max_HP())
	
	generate_lifebar()
	generate_clickable_area()


#### LOGIC ####

func generate_lifebar():
	lifebar = lifebar_scene.instance()
	var sprite = get_node_or_null("Sprite")
	
	if sprite == null:
		sprite = get_node_or_null("AnimatedSprite")
	
	if !sprite:
		return
	
	var texture = get_sprite_texture(sprite)
	
	if texture == null:
		return
	
	var sprite_height = texture.get_size().y
	lifebar.set_position(Vector2(0, -sprite_height - 5))
	lifebar.set_visible(false)
	add_child(lifebar)


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
func generate_clickable_area():
	clickable_area = Area2D.new()
	add_child(clickable_area)
	
	clickable_area.owner = self
	
	var sprite = sprite_node if sprite_node != null else animated_sprite_node
	
	clickable_area.set_position(sprite.get_position())

	var collision_shape = CollisionShape2D.new()
	
	var rect_shape = RectangleShape2D.new()
	var sprite_size = get_sprite_texture(sprite).get_size()
	rect_shape.set_extents(sprite_size / 2)
	
	collision_shape.set_shape(rect_shape)
	
	clickable_area.add_child(collision_shape)

	var _err = clickable_area.connect("mouse_entered", self, "_on_mouse_entered")
	_err = clickable_area.connect("mouse_exited", self, "_on_mouse_exited")


# Show the known actors infos
func show_infos():
	lifebar.update()
	lifebar.set_visible(true)
	EVENTS.emit_signal("iso_object_focused", self)

# Hide the infos 
func hide_infos():
	lifebar.set_visible(false)
	EVENTS.emit_signal("iso_object_unfocused", self)


func hurt(damage: int):
	set_current_HP(Math.clampi(get_current_HP() - damage, 0, get_max_HP()))
	$AnimationPlayer.play("RedFlash")
	yield($AnimationPlayer, "animation_finished")
	
	EVENTS.emit_signal("damage_inflicted", damage, self)
	emit_signal("hurt_animation_finished")
	
	if get_current_HP() == 0:
		destroy()


func destroy():
	EVENTS.emit_signal("iso_object_unfocused", self)
	EVENTS.emit_signal("scatter_object", self, 16)
	.destroy()


#### SIGNAL RESPONSES ####

func _on_mouse_entered():
	mouse_inside = true
	if not self == owner.active_actor && is_in_view_field():
		show_infos()

func _on_mouse_exited():
	mouse_inside = false
	if not self == owner.active_actor:
		hide_infos()

func _on_unfocus_all_iso_object_query():
	hide_infos()
