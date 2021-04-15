extends Node

onready var target_texture = get_parent()
onready var glitch_cool_down = $GlitchCoolDown
onready var glitch_timer_node = $GlitchDuration
onready var sub_glitch_timer_node = $SubGlitchDuration

onready var audio_streams_array = $Sounds.get_children()

export var sound_volume : float = 0.0

var glitch : bool = false

func _ready():
	var _err = glitch_timer_node.connect("timeout", self, "on_glitch_duration_timeout")
	_err = sub_glitch_timer_node.connect("timeout", self, "on_sub_glitch_duration_timeout")
	_err = glitch_cool_down.connect("timeout", self, "on_cooldown_timeout")
	
	var glitch_bus_id = AudioServer.get_bus_index("Glitch")
	AudioServer.set_bus_volume_db(glitch_bus_id, sound_volume)


func on_glitch_duration_timeout():
	glitch_timer_node.stop()
	sub_glitch_timer_node.stop()
	var shader_material = target_texture.get_material()
	shader_material.set_shader_param("apply", false)
	
	glitch_cool_down.set_wait_time(rand_range(3.5, 5.0))
	glitch_cool_down.start()


func on_sub_glitch_duration_timeout():
	generate_glitch()


func on_cooldown_timeout():
	glitch_timer_node.set_wait_time(rand_range(0.3, 0.7))
	glitch_timer_node.start()
	
	generate_glitch()



func generate_glitch():
	var shader_material = target_texture.get_material()
	
	# Play a random audio stream
	var stream_rng = randi() % len(audio_streams_array)
	audio_streams_array[stream_rng].play()
	
	# Get a random sign
	var rng_sign = sign(randf() - 0.5)
	
	shader_material.set_shader_param("apply", true)
	shader_material.set_shader_param("displace_amount", int(rand_range(30.0, 60.0) * rng_sign))
	shader_material.set_shader_param("aberation_amount", rand_range(-10.0, 10.0))
	
	sub_glitch_timer_node.set_wait_time(rand_range(0.05, 0.1))
	sub_glitch_timer_node.start()
