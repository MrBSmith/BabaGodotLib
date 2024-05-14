tool
extends Control
class_name CollectableCounter

enum SPRITE_SIZE_PRESET {
	BIG,
	MEDIUM,
	SMALL,
	MONOCHROME_SMALL
}

enum COLLECTABLE_TYPE {
	SCREW,
	GEAR
}

export(SPRITE_SIZE_PRESET) var sprite_preset : int = SPRITE_SIZE_PRESET.MEDIUM setget set_sprite_preset

export var screw_sprites_array = []
export var gear_sprites_array = []

export var maximum_amount : int = 0
export(COLLECTABLE_TYPE) var collectable_type : int = COLLECTABLE_TYPE.SCREW setget set_collectable_type

export var growth_feedback_duration : float = 0.08

export(int, 3, 9) var nb_digits = 4 

onready var sprites_array = [screw_sprites_array, gear_sprites_array] 

onready var counter_label = $"%Counter"
onready var unfilled_counter = $"%UnfilledCounter"
onready var counter_shadow = get_node_or_null("%CounterShadow")

onready var collectable_texture = $"%CollectableTexture"
onready var base_texture_scale = collectable_texture.get_scale()

signal collectable_animation_finished

var hidden : bool = false setget set_hidden
var tween : SceneTreeTween

var is_ready : bool = false

signal hidden_changed

#### ACCESSORS ####

func is_class(value: String): return value == "CollectableCounter" or .is_class(value)
func get_class() -> String: return "CollectableCounter"

func set_hidden(value: bool) -> void:
	if value != hidden:
		hidden = value
		emit_signal("hidden_changed")


func set_sprite_preset(value: int) -> void:
	if value < 0 or value > SPRITE_SIZE_PRESET.size() - 1:
		push_error("The given sprite preset value %d is out of range" % value)
		return
	
	sprite_preset = value
	_update_texture()


func set_collectable_type(value: int) -> void:
	if value < 0 or value > COLLECTABLE_TYPE.size() - 1:
		push_error("The given collectable type value %d is out of range" % value)
		return
	
	collectable_type = value
	_update_texture()


#### BUILT-IN ####

func _ready() -> void:
	var __ = EVENTS.connect("collectable_amount_updated", self, "_on_EVENTS_collectable_amount_updated")
	__ = counter_label.connect("text_changed", self, "_on_CounterLabel_text_changed")
	__ = counter_label.connect("amount_changed", self, "_on_CounterLabel_amount_changed")
	
	var collectable_name = COLLECTABLE_TYPE.keys()[collectable_type].to_lower().capitalize()
	
	if !Engine.editor_hint:
		set_amount(PROGRESSION.collectables[collectable_name], true)
	
	is_ready = true


#### VIRTUALS ####



#### LOGIC ####




func set_amount(amount: int, instant: bool = false) -> void:
	if instant:
		counter_label.reset(amount)
	else:
		counter_label.tween_amount(amount, 0.5)


func _texture_growth_feedback() -> void:
	tween = create_tween()
	
	var texture = collectable_texture
	var __ = tween.set_trans(Tween.TRANS_CUBIC)
	
	__ = tween.tween_property(texture, "rect_scale", base_texture_scale * 1.6, growth_feedback_duration * (2.0 / 3.0))
	__ = tween.tween_property(texture, "rect_scale", base_texture_scale, growth_feedback_duration * (1.0 / 3.0))


func _update_texture() -> void:
	if !is_ready:
		yield(self, "ready")
	
	collectable_texture.set_texture(sprites_array[collectable_type][sprite_preset])


func get_collectable_type_by_name(collectable_name: String) -> int:
	return COLLECTABLE_TYPE.keys().find(collectable_name.to_upper().replace(" ", "_"))


#### INPUTS ####



#### SIGNAL RESPONSES ####


func _on_obj_collect_animation_finished():
	emit_signal("collectable_animation_finished", name)
	

func _on_EVENTS_collectable_amount_updated(col_type: String, amount: int):
	if get_collectable_type_by_name(col_type) != collectable_type:
		return
	
	set_amount(amount, amount == 0)


func _on_CounterLabel_amount_changed(previous_amount : int , new_amount : int) -> void:
	if hidden:
		yield(self, "hidden_changed")
	
	if new_amount > previous_amount and (tween == null or !tween.is_running()):
		_texture_growth_feedback()


func _on_CounterLabel_text_changed(text: String) -> void:
	var nb_zeros = nb_digits - text.length()
	var zeros = ""
	
	for _i in range(nb_zeros):
		zeros += "0"
	
	var unfilled_text = zeros + text
	
	unfilled_counter.set_text(unfilled_text)
	
	if counter_shadow:
		counter_shadow.set_text(unfilled_text)
