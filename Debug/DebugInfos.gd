extends VBoxContainer
class_name DebugInfo

# A VBoxContainer useful to display the owner properties via labels
# Each Labels must be direct children and have a name that corresponds to a property of the owner (case insensitive)


#### ACCESSORS ####


#### BUILT-IN ####

func _process(_delta: float) -> void:
	if visible:
		for child in get_children():
			var property = str(child.name).to_lower()
			var value = owner.get(property)
			
			if value == null:
				continue
			
			child.set_text("%s : %s" % [property, str(value)])


#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####
