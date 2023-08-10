extends Logger
class_name NullLogger

# A logger class that does nothing, meant to be used as a proxy when no factory if provided

func debug(_msg: String) -> void:
	pass


func warning(_msg: String) -> void:
	pass


func error(_msg: String) -> void:
	pass
