extends LineData
class_name IconLineData

var icon_array : Array setget set_icon_array, get_icon_array

#### ACCESSORS ####

func is_class(value: String): return value == "IconLineData" or .is_class(value)
func get_class() -> String: return "IconLineData"

func set_icon_array(value_array: Array):
	for elem in value_array:
		if not elem is Texture:
			return
	
	icon_array = value_array

func get_icon_array() -> Array: return icon_array

#### BUILT-IN ####

func _init(icons: Array) -> void:
	set_icon_array(icons)


#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####
