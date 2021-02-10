extends Node
class_name EventsBase

#### A base class for the Events autoload

# This class must contain only signals
# You can inherit this class if you need to add your own global signals

# It is usefull to decouple systems without having to fetch 
# their references to connect their signal directly

# Instead: the emitter send a signal using: Events.emit_signal("signal_name", some_arguments, ...)
# The receiver must connect the signal: Events.connect("signal_name", self, "_on_signal_name")

# Take care not to overuse this!
# Please use this class only if you need two entities 
# to interact without knowing about each other

####


# warnings-disable

signal gameover()
signal win()

#### PATHFINDER ####

signal query_path(who, from, to)
signal send_path(who, path)


#### INTERACTIONS ####

signal interact()
signal collect(obj)
signal collectable_collected(obj, amount)
signal collectable_amount_changed(collectable_type, amount)
