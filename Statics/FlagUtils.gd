extends Node
class_name FlagUtils


## Check if ALL the bits of mask are on in flag, and ignore the other bits
static func all_bits_masked(flag: int, mask: int) -> bool:
	var common_bits = flag & mask
	return common_bits == mask


