extends LineData
class_name IconsLineData

var icons_array : Array : get = get_icons_array, set = set_icons_array

#### ACCESSORS ####

func is_class(value: String): return value == "IconsLineData" or super.is_class(value)
func get_class() -> String: return "IconsLineData"

func set_icons_array(value_array: Array):
	for elem in value_array:
		if not elem is Texture2D:
			return
	
	icons_array = value_array

func get_icons_array() -> Array: return icons_array

#### BUILT-IN ####

func _init(icons: Array):
	set_icons_array(icons)


#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####
