extends Object
class_name LoggerFactory

static func get_from_path(node: Node, logger_path: NodePath) -> Logger:
	var logger = node.get_node_or_null(logger_path)
	
	if logger == null:
		return NullLogger.new()
	
	return logger
