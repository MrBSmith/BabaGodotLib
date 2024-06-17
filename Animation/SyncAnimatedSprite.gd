tool
extends AnimatedSprite
class_name SyncAnimatedSprite

export var master_path : NodePath
export var logger_path : NodePath

export var sync_frame_rate : bool = true
export var sync_flip : bool = true

onready var master_anim_sprite : SyncAnimatedSprite = get_node_or_null(master_path)
onready var logger : Logger = LoggerFactory.get_from_path(self, logger_path)

onready var sprite_offset = offset
 
export var auto_start := false

signal animation_changed(anim, backwards)
signal flip_changed()

var is_ready = false

#### ACCESSORS ####

func is_class(value: String): return value == "SyncAnimatedSprite" or .is_class(value)
func get_class() -> String: return "SyncAnimatedSprite"


#### BUILT-IN ####

func _ready() -> void:
	if master_path.is_empty() && get_parent().is_class("SyncAnimatedSprite"):
		master_anim_sprite = get_parent()
	
	if master_anim_sprite != null:
		var __ = master_anim_sprite.connect("frame_changed", self, "_on_master_frame_changed")
		
		__ = master_anim_sprite.connect("flip_changed", self, "_on_master_flipped_changed")
		if master_anim_sprite.is_class("SyncAnimatedSprite"):
			__ = master_anim_sprite.connect("animation_changed", self, "_on_master_animation_changed")
	
	var __ = connect("frame_changed", self, "_on_frame_changed")
	
	is_ready = true
	
	if auto_start and !Engine.editor_hint:
		play(animation)


#### VIRTUALS ####



#### LOGIC ####

# FUNCTION OVERRIDE #
func play(anim: String = "", backwards: bool = false) -> void:
	if (anim == "" and get_animation() != "default") or anim != get_animation():
		emit_signal("animation_changed", anim, backwards)
	
	logger.debug("Animation %s triggered" % anim)
	.play(anim, backwards)


func set_animation(anim: String) -> void:
	if (anim == "" and get_animation() != "default") or anim != get_animation():
		.set_animation(anim)
		emit_signal("animation_changed", anim, false)


func set_flip_h(value: bool) -> void:
	.set_flip_h(value)
	
	if !is_ready:
		yield(self, "ready")
	
	# Flip the sprite's x position
	offset.x = sprite_offset.x * Math.bool_to_sign(!value)
	
	emit_signal("flip_changed")


#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_master_frame_changed() -> void:
	if sync_frame_rate && frames != null:
		set_frame(get_parent().get_frame())


func _on_master_animation_changed(anim: String = "", _backwards: bool = false) -> void:
	if frames != null && frames.has_animation(anim):
		set_animation(anim)


func _on_frame_changed() -> void:
	logger.debug("Current anim: %s Frame id: %d" % [animation, frame])


func _on_master_flipped_changed() -> void:
	if sync_flip:
		set_flip_h(master_anim_sprite.flip_h)
		set_flip_v(master_anim_sprite.flip_v)
