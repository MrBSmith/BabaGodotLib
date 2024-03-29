extends UIAnimationModule
class_name OpeningAnimationModule

enum MARGINS {
	LEFT = 1,
	TOP = 2,
	RIGHT = 4,
	BOTTOM = 8
}

enum START_MODE {
	START_CLOSED,
	START_OPENED
}

enum ANIMATION_MODE {
	TOGGLE,
	BOTH
}

export(START_MODE) var start_mode = START_MODE.START_CLOSED
export(ANIMATION_MODE) var anim_mode = ANIMATION_MODE.TOGGLE
export(int, FLAGS, "Left", "Top", "Right", "Bottom") var animated_margins : int = MARGINS.RIGHT | MARGINS.LEFT

onready var closed : bool = false if start_mode == START_MODE.START_OPENED else true
onready var default_margins_array : Array = []

var default_size := Vector2.INF setget set_default_size

export var print_logs : bool = false

signal resize_finished

#### ACCESSORS ####

func is_class(value: String): return value == "OpeningAnimationModule" or .is_class(value)
func get_class() -> String: return "OpeningAnimationModule"

func set_default_size(value: Vector2) -> void:
	if not value in [default_size, Vector2.INF]:
		default_size = value

#### BUILT-IN ####

func _ready() -> void:
	if disabled:
		return
	
	if start_mode == START_MODE.START_CLOSED:
		if target == null:
			yield(self, "target_changed")
		
		close_instant()



#### VIRTUALS ####

func play() -> void:
	target.set_visible(true)
	
	_open_animation()
	yield(self, "resize_finished")
	
	if anim_mode == ANIMATION_MODE.BOTH:
		_open_animation()
		yield(self, "resize_finished")
	
	emit_signal("animation_finished")


#### LOGIC ####

func update_default_params() -> void:
	set_default_size(target.rect_size)
	default_margins_array = _fetch_default_margin()
	
	if print_logs:
		print("default param for %s updated" % target.name)
		print("default_size: %s" % str(target.rect_size))
		print("default_margins_array: %s" % str(default_margins_array))


func _fetch_default_margin() -> Array:
	var array = []
	
	for margin in range(4):
		array.append(target.get_margin(margin))
	
	return array


func close_instant() -> void:
	closed = true
	
	for margin in range(4):
		if animated_margins & MARGINS.values()[margin]:
			target.set_margin(margin, 0.0)
	
	target.set_visible(false)


# Resize animation
func _open_animation() -> void:
	var tween = create_tween()
	var ease_type = ease_type_in if closed else ease_type_out
	var trans_type = trans_type_in if closed else trans_type_out
	
	tween.set_ease(ease_type)
	tween.set_trans(trans_type)
	
	for margin in range(4):
		var bit_margin = MARGINS.values()[margin]
		if !(animated_margins & bit_margin):
			continue
		
		var default_size_axis = default_size.x if margin in [MARGIN_LEFT, MARGIN_RIGHT] else default_size.y
		var from = default_size_axis if closed else 0.0
		var to = 0.0 if closed else default_size_axis
		
		# If the opposite margin is also animated
		if animated_margins & MARGINS.values()[margin - 2]:
			from /= 2.0
			to /= 2.0
		
		var margin_name = "margin_" + MARGINS.keys()[margin].to_lower()
		var origin_value = default_margins_array[margin] + from * Math.bool_to_sign(margin < 2)
		var dest_value = default_margins_array[margin] + to * Math.bool_to_sign(margin < 2)
		
		if print_logs:
			print("animate %s form: %s to: %s" % [margin_name, str(origin_value), str(dest_value)])
		
		target.set_margin(margin, origin_value)
		tween.parallel().tween_property(target, margin_name, dest_value, anim_duration)
	
	yield(tween, "finished")
	closed = !closed
	
	if print_logs:
		print("%s animation finished: closed is now %s" % [target.name, str(closed)])
	
	emit_signal("resize_finished")



#### INPUTS ####



#### SIGNAL RESPONSES ####


func _on_animation_finished() -> void:
	if closed:
		target.set_visible(false)
	

func _on_target_changed() -> void:
	update_default_params()
