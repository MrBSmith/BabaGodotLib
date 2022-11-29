extends HBoxContainer
class_name CollectableCounter

@export var maximum_amount : int = 0
@export var collectable_type : String = ""

@onready var counter_label = $CounterLabel
@onready var base_texture_scale = $Texture2D.get_scale()

var tween : Tween

signal collectable_animation_finished


#### ACCESSORS ####

func is_class(value: String): return value == "CollectableCounter" or super.is_class(value)
func get_class() -> String: return "CollectableCounter"


#### BUILT-IN ####

func _ready() -> void:
	EVENTS.collectable_amount_updated.connect(_on_collectable_amount_updated)


#### VIRTUALS ####



#### LOGIC ####

func set_amount(amount: int, instant: bool = false) -> void:
	if instant:
		counter_label.set_amount(amount)
	else:
		counter_label.tween_amount(amount, 0.5)


func _texture_growth_feedback() -> void:
	if is_instance_valid(tween) && tween != null:
		tween.kill()
	
	tween = create_tween()
	
	var texture = $Texture2D
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(texture, "scale", base_texture_scale * 1.4, 0.2)
	tween.tween_property(texture, "scale", base_texture_scale, 0.1)





#### INPUTS ####



#### SIGNAL RESPONSES ####


func _on_obj_collect_animation_finished():
	emit_signal("collectable_animation_finished", name)
	

func _on_collectable_amount_updated(col_type: String, amount: int):
	if col_type != collectable_type:
		return
	
	set_amount(amount)


func _on_CounterLabel_amount_changed(previous_amount : int , new_amount : int) -> void:
	if hidden:
		await self.hidden_changed
	
	if new_amount > previous_amount:
		_texture_growth_feedback()
