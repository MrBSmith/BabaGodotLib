extends Tween
class_name IsoRendererTween

var base_dist = GAME.TILE_SIZE.y / 2

var dir := Vector2.DOWN

#### ACCESSORS ####

func is_class(value: String): return value == "IsoRendererTween" or .is_class(value)
func get_class() -> String: return "IsoRendererTween"


#### BUILT-IN ####


func _ready() -> void:
	var _err = connect("tween_completed", self, "_on_tween_completed")


#### VIRTUALS ####



#### LOGIC ####

func appear(part: RenderPart, duration: float, delay: float = 0.0):
	var __ = interpolate_property(part, "position",
		Vector2(0, -GAME.SCREEN_SIZE.y), Vector2.ZERO, duration,
		Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, delay)
	
	__ = start()


func disapear(part: RenderPart, duration: float, delay: float = 0.0):
	var __ = interpolate_property(part, "position",
		Vector2.ZERO, Vector2(0, GAME.SCREEN_SIZE.y), duration,
		Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, delay)
	
	__ = start()


func start_sin_move(part: RenderPart, magn: int, duration: float = 0.7, 
		nb_vawes : int = 1, delay: float = 0.0) -> void:
	
	part.sin_mov_magnitude = magn
	part.sin_nb_movements = nb_vawes * 2
	part.sin_mov_duration = duration
	part.sin_mov_origin = part.get_position()
	
	start_wave_interpolation(part, false, delay)


func start_wave_interpolation(part: RenderPart, to_origin : bool = false, delay: float = 0.0) -> void:
	var dest = part.sin_mov_origin + dir * base_dist * part.sin_mov_magnitude if !to_origin else part.sin_mov_origin
	var duration = part.sin_mov_duration / (part.sin_nb_movements + 1)
	
	var __ = interpolate_property(part, "position", part.position, dest, duration,
		TRANS_LINEAR, EASE_IN_OUT, delay)
	
	__ = start()


#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_tween_completed(obj: Object, _key: NodePath):
	if obj.sin_nb_movements == 0:
		return
	
	obj.sin_nb_movements -= 1
	obj.sin_movement_dir = -obj.sin_movement_dir
	
	start_wave_interpolation(obj, obj.sin_nb_movements == 0)
