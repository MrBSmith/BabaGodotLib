tool
extends Control
class_name BlackBars

export var bars_width : float = 24.0 setget set_bars_width

onready var top_bar_hidden_pos = $TopBar.get_position()
onready var bottom_bar_hidden_pos = $BottomBar.get_position()

onready var bars_array = [$TopBar, $BottomBar]

signal bars_width_changed

#### ACCESSORS ####

func is_class(value: String): return value == "BlackBars" or .is_class(value)
func get_class() -> String: return "BlackBars"

func set_bars_width(value: float) -> void:
	if bars_width != value:
		bars_width = value
		emit_signal("bars_width_changed", bars_width)


#### BUILT-IN ####

func _ready() -> void:
	var __ = connect("bars_width_changed", self, "_on_bars_width_changed")


#### VIRTUALS ####



#### LOGIC ####

func appear(disapear: bool = false, duration: float = 1.5) -> void:
	var tween
	
	for bar in bars_array:
		tween = create_tween()
		var is_top_bar = bar == $TopBar
		var to = top_bar_hidden_pos.y if is_top_bar else bottom_bar_hidden_pos.y
		var offset = bar.rect_size.y * Math.bool_to_sign(is_top_bar) if !disapear else 0.0
		
		tween.tween_property(bar, "rect_position:y", to + offset, duration).set_trans(Tween.TRANS_SINE)
	
	yield(tween, "finished")
	set_visible(!disapear)


func disapear(duration: float = 1.5) -> void:
	appear(true, duration)



#### INPUTS ####




#### SIGNAL RESPONSES ####

func _on_bars_width_changed(width: float) -> void:
	for bar in bars_array:
		bar.rect_size.y = width
		
		if bar == $TopBar:
			bar.rect_position.y = -width
