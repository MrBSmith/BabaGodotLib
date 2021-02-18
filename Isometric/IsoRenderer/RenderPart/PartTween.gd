extends Tween
class_name PartTween

const BASE_DIST = GAME.TILE_SIZE.y / 2

var target_node : Node = null

var dir := Vector2.DOWN
var total_time : float = 0.0
var magnitude : float = 0.0

var nb_movements : int = 0
var movement_counter : int = 0

#### ACCESSORS ####

func is_class(value: String): return value == "PartTween" or .is_class(value)
func get_class() -> String: return "PartTween"


#### BUILT-IN ####


func _ready() -> void:
	var _err = connect("tween_all_completed", self, "_on_tween_all_completed")


#### VIRTUALS ####



#### LOGIC ####

func appear(duration: float):
	var __ = interpolate_property(target_node, "position",
		Vector2(0, -GAME.SCREEN_SIZE.y), Vector2.ZERO, duration,
		Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	
	__ = start()


func disapear(duration: float):
	var __ = interpolate_property(target_node, "position",
		Vector2.ZERO, Vector2(0, GAME.SCREEN_SIZE.y), duration,
		Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	
	__ = start()


func start_sin_move(node: Node, magn: int, duration: float = 0.7, nb_vawes : int = 1):
	target_node = node
	magnitude = magn
	total_time = duration
	nb_movements = nb_vawes * 2
	movement_counter = nb_movements
	
	start_wave_interpolation()


func start_wave_interpolation(to_origin : bool = false):
	var dest = dir * BASE_DIST * magnitude if !to_origin else Vector2.ZERO
	var duration = total_time / (nb_movements + 1)
	
	var __ = interpolate_property(target_node, "position",
		target_node.position, dest, duration,
		Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	
	__ = start()


#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_tween_all_completed():
	if movement_counter == 0:
		return
	
	movement_counter -= 1
	dir = -dir
	
	start_wave_interpolation(movement_counter == 0)
