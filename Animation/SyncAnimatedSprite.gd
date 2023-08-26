extends AnimatedSprite
class_name SyncAnimatedSprite

export var master_path : NodePath
export var logger_path : NodePath

export var sync_frame_rate : bool = true

onready var master_anim_sprite : SyncAnimatedSprite = get_node_or_null(master_path)
onready var logger : Logger = LoggerFactory.get_from_path(self, logger_path)

onready var sprite_offset = offset
 
signal animation_changed(anim, backwards)

#### ACCESSORS ####

func is_class(value: String): return value == "SyncAnimatedSprite" or .is_class(value)
func get_class() -> String: return "SyncAnimatedSprite"


#### BUILT-IN ####

func _ready() -> void:
	if master_path.is_empty() && get_parent().is_class("SyncAnimatedSprite"):
		master_anim_sprite = get_parent()
	
	if master_anim_sprite != null:
		var __ = master_anim_sprite.connect("frame_changed", self, "_on_parent_frame_changed")
		
		if master_anim_sprite.is_class("SyncAnimatedSprite"):
			__ = master_anim_sprite.connect("animation_changed", self, "_on_parent_animation_changed")
	
	var __ = connect("frame_changed", self, "_on_frame_changed")

#### VIRTUALS ####



#### LOGIC ####

# FUNCTION OVERRIDE #
func play(anim: String = "", backwards: bool = false) -> void:
	if (anim == "" and get_animation() != "default") or anim != get_animation():
		emit_signal("animation_changed", anim, backwards)
	
	logger.debug("Animation %s triggered" % anim)
	.play(anim, backwards)


func set_flip_h(value: bool) -> void:
	.set_flip_h(value)
	
	# Flip the sprite's x position
	position.x = abs(position.x) * Math.bool_to_sign(!value)
	offset.x = sprite_offset.x * Math.bool_to_sign(!value)


#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_parent_frame_changed() -> void:
	if sync_frame_rate && frames != null:
		set_frame(get_parent().get_frame())


func _on_parent_animation_changed(anim: String = "", _backwards: bool = false) -> void:
	if frames != null && frames.has_animation(anim):
		set_animation(anim)

func _on_frame_changed() -> void:
	logger.debug("Frame changed %d" % frame)
