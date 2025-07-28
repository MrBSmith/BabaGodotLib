extends Node
class_name TraitFinder

## This function search for a trait of the given type in the given obj
## This is a very slow process so, please avoid using this at runtime when possible
static func find_trait(obj: Object, trait_type: Variant) -> Trait:
	var script : Script = obj.get_script()
	var properties = script.get_script_property_list()

	for property in properties:
		var value = obj.get(property.name)
		if is_instance_of(value, trait_type):
			return value as Trait
	return null


static func has_trait(obj: Object, trait_type: Variant) -> bool:
	return find_trait(obj, trait_type) != null
