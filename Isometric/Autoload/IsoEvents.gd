extends EventsBase
class_name IsoEvents

# warnings-disable

#### IsoMap EVENTS ####

signal appear_transition()
signal disappear_transition()

signal cursor_world_pos_changed(cursor)
signal cursor_cell_changed(cursor, cell)
signal visible_cells_changed()
signal iso_object_cell_changed(iso_object)

signal iso_object_added(iso_object)
signal iso_object_removed(iso_object)

signal actor_moved(actor, from_cell, to_cell)

signal tiles_shake(origin, magnitude)

# Disable standart Godot rendering by hiding every IsoObject and IsoMapLayer. 
# Usefull if you use the IsoRenderer
signal hide_iso_objects(hide)
