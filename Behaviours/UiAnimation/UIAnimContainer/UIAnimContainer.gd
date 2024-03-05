tool 
extends Control
class_name UIAnimContainer

enum SORTING_TYPE {
	HORIZONTAL,
	VERTICAL
}

enum ADAPT_FLAGS {
	CHILDREN_SIZE_X = 1,
	CHILDREN_SIZE_Y = 2,
	CHILDREN_POS_X = 4,
	CHILDREN_POS_Y = 8,
	CONTAINER_SIZE_X = 16,
	CONTAINER_SIZE_Y = 32
}

export(SORTING_TYPE) var sorting_type : int = SORTING_TYPE.HORIZONTAL setget set_sorting_type
export var ignored_nodes : Array = []

export(int, -9999, 9999) var separation : int = 4 setget set_separation

export(int, FLAGS, "children_size_x", "children_size_y", 
	"children_pos_x", "children_pos_y", "container_size_x", 
	"container_size_y") var adapt_flags : int = 15 setget set_adapt_flags

export var print_logs : bool = false

var is_ready = false
var pending_sort = false

signal sort_children
signal sorting_type_changed
signal separation_changed
signal adapt_flags_changed

#### ACCESSORS ####

func is_class(value: String): return value == "UIAnimContainer" or .is_class(value)
func get_class() -> String: return "UIAnimContainer"

func set_sorting_type(value: int) -> void:
	if not value in SORTING_TYPE.values():
		push_error("The given sorting type value is out of range")
		return
	
	if value != sorting_type:
		sorting_type = value
		emit_signal("sorting_type_changed")

func set_separation(value: int) -> void:
	if value != separation:
		separation = value
		emit_signal("separation_changed")

func set_adapt_flags(value: int) -> void:
	var added_value : int = value - adapt_flags
	if added_value > 0:
		match(added_value):
			ADAPT_FLAGS.CHILDREN_SIZE_X: 
				if value & ADAPT_FLAGS.CONTAINER_SIZE_X:
					value -= ADAPT_FLAGS.CONTAINER_SIZE_X
			
			ADAPT_FLAGS.CHILDREN_SIZE_Y: 
				if value & ADAPT_FLAGS.CONTAINER_SIZE_Y:
					value -= ADAPT_FLAGS.CONTAINER_SIZE_Y
			
			ADAPT_FLAGS.CONTAINER_SIZE_X: 
				if value & ADAPT_FLAGS.CHILDREN_SIZE_X:
					value -= ADAPT_FLAGS.CHILDREN_SIZE_X
			
			ADAPT_FLAGS.CONTAINER_SIZE_Y: 
				if value & ADAPT_FLAGS.CHILDREN_SIZE_Y:
					value -= ADAPT_FLAGS.CHILDREN_SIZE_Y
	
	if value != adapt_flags:
		adapt_flags = value
		emit_signal("adapt_flags_changed")


#### BUILT-IN ####

func _ready() -> void:
	var __ = connect("sort_children", self, "_on_sort_children")
	__ = connect("separation_changed", self, "_on_separation_changed")
	__ = connect("sorting_type_changed", self, "_on_sorting_type_changed")
	__ = connect("resized", self, "_on_resized")
	__ = connect("child_entered_tree", self, "_on_child_entered_tree")
	__ = connect("adapt_flags_changed", self, "_on_adapt_flags_changed")
	
	for child in get_children():
		if child is Control:
			connect_child_signals(child)
	
	is_ready = true

#### VIRTUALS ####



#### LOGIC ####

func _update_container() -> void:
	if !is_ready:
		yield(self, "ready")
	
	if pending_sort:
		return
	
	pending_sort = true
	
	if print_logs:
		print("Update container: %s" % name)
	
	_update_size()
	_resort()
	
	pending_sort = false


func _resort() -> void:
	if print_logs:
		print("%s sort its children" % name)
	
	var child_axis_size = 0.0
	var visible_children = []
	var non_expand_children = []
	var non_expand_chidren_sum = 0.0
	
	for child in get_children():
		if _is_node_ignored(child):
			continue
		
		if child is Control && child.visible:
			visible_children.append(child)
			
			# Compute the sum size on axis x or y based on the sorting type
			if sorting_type == SORTING_TYPE.HORIZONTAL && !(child.size_flags_horizontal & SIZE_EXPAND):
				non_expand_chidren_sum += child.rect_size.x
				non_expand_children.append(child)
			
			elif sorting_type == SORTING_TYPE.VERTICAL && !(child.size_flags_vertical & SIZE_EXPAND):
				non_expand_chidren_sum += child.rect_size.y
				non_expand_children.append(child)
	
	if visible_children.empty():
		return
	
	var nb_intervals = visible_children.size() - 1
	var nb_expand_children = visible_children.size() - non_expand_children.size()
	
	# Find the size of expand children
	if nb_expand_children != 0:
		var rect_axis = rect_size.x if sorting_type == SORTING_TYPE.HORIZONTAL else rect_size.y
		var total_separation = separation * nb_intervals
		
		child_axis_size = ((rect_axis - total_separation - non_expand_chidren_sum) / nb_expand_children) 
	
	
	for i in range(visible_children.size()):
		var child = visible_children[i]
		var children_before_sum = 0.0
		var size = child.rect_size
		var pos = child.rect_position
		
		# Get the sum of the size of each children before 
		for j in range(i):
			var child_before = visible_children[j]
			
			if sorting_type == SORTING_TYPE.HORIZONTAL:
				children_before_sum += child_before.rect_size.x
			else:
				children_before_sum += child_before.rect_size.y
		
		# Apply new size & position
		if sorting_type == SORTING_TYPE.HORIZONTAL:
			if adapt_flags & ADAPT_FLAGS.CHILDREN_SIZE_X:
				if child.size_flags_horizontal & SIZE_EXPAND:
					size.x = child_axis_size
				else:
					size.x = 0.0
				
			if adapt_flags & ADAPT_FLAGS.CHILDREN_SIZE_Y:
				size.y = rect_size.y
			
			if adapt_flags & ADAPT_FLAGS.CHILDREN_POS_X:
				pos.x = children_before_sum + separation * i
			
			if adapt_flags & ADAPT_FLAGS.CHILDREN_POS_Y:
				pos.y = 0.0
		else:
			if adapt_flags & ADAPT_FLAGS.CHILDREN_SIZE_X:
				size.x = rect_size.x
			
			if adapt_flags & ADAPT_FLAGS.CHILDREN_SIZE_Y:
				if child.size_flags_vertical & SIZE_EXPAND:
					size.y = child_axis_size
				else:
					size.y = 0.0
			
			if adapt_flags & ADAPT_FLAGS.CHILDREN_POS_X:
				pos.x = 0.0
				
			if adapt_flags & ADAPT_FLAGS.CHILDREN_POS_Y:
				pos.y = children_before_sum + separation * i
		
		if !child.rect_size.is_equal_approx(size):
			child.rect_size = size
		
		if !child.rect_position.is_equal_approx(pos):
			child.rect_position = pos


func _update_size() -> void:
	var visible_children = []
	
	for child in get_children():
		if _is_node_ignored(child):
			continue
		
		elif child is Control && child.visible:
			visible_children.append(child)
	
	var nb_intervals = Math.clampi(visible_children.size() - 1, 0, 9999)
	
	var children_axis_sum := 0.0
	var biggest_child_axis := 0.0
	
	for child in visible_children:
		if sorting_type == SORTING_TYPE.HORIZONTAL:
			children_axis_sum += child.rect_size.x
			if child.rect_size.y > biggest_child_axis:
				biggest_child_axis = child.rect_size.y
			
		if sorting_type == SORTING_TYPE.VERTICAL:
			children_axis_sum += child.rect_size.y
			if child.rect_size.x > biggest_child_axis:
				biggest_child_axis = child.rect_size.x
	
	if sorting_type == SORTING_TYPE.HORIZONTAL:
		if adapt_flags & ADAPT_FLAGS.CONTAINER_SIZE_X:
			var size_x = children_axis_sum + nb_intervals * separation
			if !is_equal_approx(size_x, rect_size.x):
				rect_size.x = size_x
		
		if adapt_flags & ADAPT_FLAGS.CONTAINER_SIZE_Y:
			var size_y = biggest_child_axis
			if !is_equal_approx(size_y, rect_size.y):
				rect_size.y = size_y

	else:
		if adapt_flags & ADAPT_FLAGS.CONTAINER_SIZE_X:
			var size_x = biggest_child_axis
			if !is_equal_approx(size_x, rect_size.x):
				rect_size.x = size_x
		
		if adapt_flags & ADAPT_FLAGS.CONTAINER_SIZE_Y:
			var size_y = children_axis_sum + nb_intervals * separation
			if !is_equal_approx(size_y, rect_size.y):
				rect_size.y = size_y
	
	if print_logs:
		print("%s updated its size %s" % [name, str(rect_size)])


func _is_node_ignored(node: Node) -> bool:
	for node_path in ignored_nodes: 
		if get_node_or_null(node_path) == node:
			return true
	return false


func connect_child_signals(child: Control) -> void:
	if !is_a_parent_of(child):
		push_error("The given node %s is not a child abort" % child.name)
	
	if !child.is_connected("resized", self, "_on_child_resized"):
		var __ = child.connect("resized", self, "_on_child_resized", [child])
	
	if !child.is_connected("visibility_changed", self, "_on_child_visibility_changed"):
		var __ = child.connect("visibility_changed", self, "_on_child_visibility_changed", [child])
	
	if !child.is_connected("size_flags_changed", self, "_on_child_size_flags_changed"):
		var __ = child.connect("size_flags_changed", self, "_on_child_size_flags_changed")


#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_sort_children() -> void:
	if print_logs:
		print("%s received sort_children signal" % name)
		
	_update_container()


func _on_separation_changed() -> void:
	emit_signal("sort_children")


func _on_sorting_type_changed() -> void:
	emit_signal("sort_children")


func _on_resized() -> void:
	emit_signal("sort_children")


func _on_child_resized(child: Node) -> void:
	if print_logs:
		print("%s's child %s has been resized; new size: %s" % [name, child.name, str(child.rect_size)])

	emit_signal("sort_children")


func _on_child_entered_tree(child: Node) -> void:
	if child is Control:
		if print_logs:
			print("%s has a new child %s" % [name, child.name])
		
		connect_child_signals(child)
		emit_signal("sort_children")


func _on_child_visibility_changed(_child: Node) -> void:
	emit_signal("sort_children")


func _on_child_size_flags_changed() -> void:
	emit_signal("sort_children")


func _on_adapt_flags_changed() -> void:
	_update_container()
