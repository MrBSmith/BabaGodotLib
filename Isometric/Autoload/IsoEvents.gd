extends EventsBase
class_name IsoEvents

# warnings-disable

#### ISOMAP EVENTS ####

signal appear_transition()
signal disappear_transition()

signal click_at_cell(cell)

signal cursor_world_pos_changed(cursor)
signal cursor_cell_changed(cursor, cell)

signal iso_object_cell_changed(iso_object)
signal iso_object_world_pos_changed(iso_object)

signal iso_object_added(iso_object)
signal iso_object_removed(iso_object)

signal iso_object_focused(obj)
signal iso_object_unfocused(obj)

signal actor_moved(actor, from_cell, to_cell)

signal action_phase_finished()

signal tiles_shake(origin, magnitude)

signal unfocus_all_iso_object_query()
signal visible_cells_changed()
signal update_rendered_visible_cells(visible_cells_array)


# Disable standart Godot rendering by hiding every IsoObject and IsoMapLayer. 
# Usefull if you use the IsoRenderer
signal hide_iso_objects(hide)
