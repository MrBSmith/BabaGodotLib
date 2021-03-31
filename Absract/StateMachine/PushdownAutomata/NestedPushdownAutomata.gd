extends PushdownAutomata
class_name NestedPushdownAutomata

#### ACCESSORS ####

func is_class(value: String): return value == "NestedPushdownAutomata" or .is_class(value)
func get_class() -> String: return "NestedPushdownAutomata"


#### BUILT-IN ####



#### VIRTUALS ####

func enter_state():
	current_state.enter_state()

func exit_state():
	current_state.exit_state()

func update():
	current_state.state()


#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####
