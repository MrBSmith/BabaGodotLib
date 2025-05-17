extends Node
class_name TraitFinder

static func find_trait(node: Node, trait_name: String) -> Trait:
	if node.has_meta(trait_name):
		return node.get_meta(trait_name, null)
	else:
		return null


static func has_trait(node: Node, trait_name: String) -> bool:
	return node.has_meta(trait_name)
