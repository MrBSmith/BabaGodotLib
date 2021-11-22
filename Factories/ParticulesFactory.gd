extends Factory
class_name ParticulesFactory

#### ACCESSORS ####

func is_class(value: String): return value == "ParticulesFactory" or .is_class(value)
func get_class() -> String: return "ParticulesFactory"


#### BUILT-IN ####

func _ready() -> void:
	var __ = EVENTS.connect("play_particule_FX", self, "_on_play_particule_FX")


#### VIRTUALS ####



#### LOGIC ####

func play_particules(particule: Particles2D, pos: Vector2) -> void:
	var new_particule = particule.duplicate()
	target.call_deferred("add_child", new_particule)
	new_particule.set_position(pos)
	new_particule.set_emitting(true)
	
	yield(get_tree().create_timer(new_particule.lifetime), "timeout")
	new_particule.queue_free()


#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_play_particule_FX(particule: Particles2D, pos: Vector2) -> void:
	play_particules(particule, pos)
