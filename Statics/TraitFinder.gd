extends Node
class_name TraitFinder

static func find_trait(node: Node, trait_class: Variant) -> Trait:
	var id = node.get_children().find_custom(func(n: Node): return is_instance_of(n, trait_class))
	return node.get_child(id) if id != -1 else null


static func has_trait(node: Node, trait_class: Variant) -> bool:
	return find_trait(node, trait_class) != null
