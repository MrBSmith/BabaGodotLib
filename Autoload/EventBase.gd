extends Node
class_name EventsBase

#### A base class for the EVENTS autoload

# This class must contain only signals
# You can inherit this class if you need to add your own global signals

# It is usefull to decouple systems without having to fetch 
# their references to connect their signal directly

# Instead: the emitter send a signal using: EVENTS.emit_signal("signal_name", some_arguments, ...)
# The receiver must connect the signal: EVENTS.connect("signal_name", self, "_on_signal_name")

# Take care not to overuse this!
# Please use this class only if you need two entities 
# to interact without knowing about each other

####


# warnings-disable

signal new_game()
signal gameover()
signal win()


#### PATHFINDER ####

signal query_path(who, from, to)
signal send_path(who, path)


#### INTERACTIONS ####

signal interact()
signal collect(obj)
signal collectable_amount_collected(obj, amount)
signal collectable_amount_updated(collectable_type, amount)
signal update_HUD()
signal approch_collactable(obj)
signal checkpoint_reached(level, checkpoint_id)

#### SFX ####

signal play_SFX(fx_name, pos)
signal scatter_object(body, nb_debris, impulse_force)


#### SOUND ####

signal play_sound_effect(stream_player)


#### DIALOGUES ####

signal dialogue_query(dialogue_index, is_cut_scene)


#### MENU ####

signal menu_cancel()
signal goto_menu_root()


#### LEVEL NAVIGATION ####

signal go_to_next_level()
signal go_to_level(level_id)
