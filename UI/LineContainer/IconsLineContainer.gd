extends LineContainer
class_name IconsLineContainer

var icons_array : Array = [] setget set_icons_array, get_icons_array

#### ACCESSORS ####

func is_class(value: String): return value == "IconsLineContainer" or .is_class(value)
func get_class() -> String: return "IconsLineContainer"

func set_icons_array(value: Array):
	if !is_ready:
		yield(self, "ready")
	
	icons_array = value
	
	for icon in icons_array:
		var texture_rect = TextureRect.new()
		
		texture_rect.set_texture(icon)
		call_deferred("add_child", texture_rect)


func get_icons_array() -> Array: return icons_array


#### BUILT-IN ####



#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####
