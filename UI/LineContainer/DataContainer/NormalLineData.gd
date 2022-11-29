extends LineData
class_name NormalLineData

var text: String = ""
var texture: Texture2D = null
var amount : int = INF

#### ACCESSORS ####

func is_class(value: String): return value == "NormalLineData" or super.is_class(value)
func get_class() -> String: return "NormalLineData"


#### BUILT-IN ####

func _init(_text: String,_texture: Texture2D = null, _amount: int = -1) -> void:
	text = _text
	texture = _texture
	amount = _amount

#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####
