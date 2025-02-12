tool
extends Control
class_name BlackBars

export var bars_width : float = 24.0 setget set_bars_width
onready var logger : Logger = $Logger

onready var top_bar_hidden_pos = $TopBar.get_position()
onready var bottom_bar_hidden_pos = $BottomBar.get_position()

onready var bars_array = [$TopBar, $BottomBar]
var bars_visible = false

signal bars_width_changed

#### ACCESSORS ####

func is_class(value: String): return value == "BlackBars" or .is_class(value)
func get_class() -> String: return "BlackBars"

func set_bars_width(value: float) -> void:
	if bars_width != value:
		bars_width = value
		emit_signal("bars_width_changed", bars_width)


func are_bars_visible() -> bool:
	return bars_visible


#### BUILT-IN ####

func _ready() -> void:
	var __ = connect("bars_width_changed", self, "_on_bars_width_changed")
	
	_on_bars_width_changed(bars_width)


#### VIRTUALS ####



#### LOGIC ####

func appear(disappear: bool = false, duration: float = 1.5) -> void:
	if bars_visible != disappear:
		return
	
	set_visible(true)
	bars_visible = true
	
	var debug_string = "appear" if !disappear else "disappear"
	logger.debug("Black bars %s transition started" % debug_string)
	
	var tween
	
	for bar in bars_array:
		tween = create_tween()
		var is_top_bar = bar == $TopBar
		var to = top_bar_hidden_pos.y if is_top_bar else bottom_bar_hidden_pos.y
		var offset = bar.rect_size.y * Math.bool_to_sign(is_top_bar) if !disappear else 0.0
		
		tween.tween_property(bar, "rect_position:y", to + offset, duration).set_trans(Tween.TRANS_SINE)
	
	yield(tween, "finished")
	set_visible(!disappear)
	if disappear:
		bars_visible = false


func disappear(duration: float = 1.5) -> void:
	appear(true, duration)



#### INPUTS ####




#### SIGNAL RESPONSES ####

func _on_bars_width_changed(width: float) -> void:
	for bar in bars_array:
		bar.rect_size.y = width
		
		if bar == $TopBar:
			bar.rect_position.y = -width



