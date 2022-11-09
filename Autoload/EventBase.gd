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
signal continue_game()
signal gameover()
signal win()
signal game_resumed()
signal quit_current_game()

signal save_game(save_id)
signal load_game(save_id)
signal save_level(level, data_dict)
signal save_level_state(level)

signal game_setting_changed(setting_name, value)

#### NETWORK ####

signal network_game_started()
signal network_game_ended()
signal network_client_left()
signal network_client_action(action)
signal network_event(events) #events should be a Dictionary of every events happened. Example: "events":{"event1",:value1,"event2":value2,...}
signal network_xl_destructible_object_destroyed(destructible_object) # Reference to the destructible object being destroyed

#### PATHFINDER ####

signal query_path(who, from, to)
signal send_path(who, path)


#### INTERACTIONS ####

signal interact()
signal collect(collectable, collectable_type)
signal increment_collectable_amount(collectable_type)
signal collectable_amount_updated(collectable_type, amount)
signal update_HUD()
signal approch_collactable(obj)
signal checkpoint_reached(checkpoint_id)

#### VFX ####

signal play_VFX(fx_name, pos, state_dict)
signal play_VFX_scene(fx_scene, pos, state_dict)
signal scatter_object(body, nb_debris, impulse_force)
signal screen_shake(magnitude, duration)

signal play_particule_FX(particules, pos)

#### SOUND ####

signal play_sound_effect(stream_player)


#### DIALOGUES ####

signal dialogue_query(dialogue_index, is_cut_scene)


#### MENU ####

signal menu_cancel()
signal goto_menu_root()
signal menu_entered(menu_name)

signal navigate_menu_query(menu_name, dest_menu_parent, current_menu)
signal navigate_menu_back_query()
signal change_scene_to_menu(menu_name, trans_duration)


#### LEVEL NAVIGATION ####

signal go_to_last_level()
signal go_to_level(level_id)
signal go_to_level_by_path(path)
signal go_to_world_map()

#### CUTSCENES ####

signal cutscene_started()
signal cutscene_finished()
