extends AnimatedSprite2D
class_name SyncAnimatedSprite

@export var sync_frame_rate : bool = true

@export var master_path : NodePath
@onready var master_anim_sprite : SyncAnimatedSprite = get_node_or_null(master_path)

@onready var sprite_offset = offset
 
#### ACCESSORS ####


#### BUILT-IN ####

func _ready() -> void:
	if master_path.is_empty() && get_parent().is_class("SyncAnimatedSprite"):
		master_anim_sprite = get_parent()
	
	if master_anim_sprite and master_anim_sprite is AnimatedSprite2D:
		master_anim_sprite.frame_changed.connect(_on_parent_frame_changed)
		master_anim_sprite.animation_changed.connect(_on_parent_animation_changed)


#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_parent_frame_changed() -> void:
	if sync_frame_rate && sprite_frames != null:
		set_frame(get_parent().get_frame())


func _on_parent_animation_changed(anim: String = "", _backwards: bool = false) -> void:
	if sprite_frames != null && sprite_frames.has_animation(anim):
		set_animation(anim)
