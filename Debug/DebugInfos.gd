extends VBoxContainer
class_name DebugInfo

# A VBoxContainer useful to display the owner properties via labels
# Each Labels must be direct children and have a name that corresponds to a property of the owner (case insensitive)


#### ACCESSORS ####


#### BUILT-IN ####

func _process(_delta: float) -> void:
	if visible:
		for child in get_children():
			var property = child.name.to_lower()
			var value
			var getter_name = "get_%s" % property
			
			if owner.has_method(getter_name):
				value = owner.call(getter_name)
			else:
				value = owner.get(property)
			
			if value == null:
				continue
			
			child.set_text("%s : %s" % [property, String(value)])


#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####
