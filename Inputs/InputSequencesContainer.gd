extends Node
class_name InputSequencesContainer

#### ACCESSORS ####

func is_class(value: String): return value == "InputSequencesContainer" or .is_class(value)
func get_class() -> String: return "InputSequencesContainer"


#### BUILT-IN ####

func _ready() -> void:
	pass

#### VIRTUALS ####



#### LOGIC ####

func test_sequences(event: InputEvent) -> void:
	for child in get_children():
		if owner.skill_dict[child.name] == false && !owner.all_skills:
			continue
		
		child.action(event)

#### INPUTS ####



#### SIGNAL RESPONSES ####
