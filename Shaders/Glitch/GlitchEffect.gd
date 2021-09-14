extends Node

onready var target_texture = get_parent()
onready var glitch_cool_down = $GlitchCoolDown
onready var glitch_timer_node = $GlitchDuration
onready var sub_glitch_timer_node = $SubGlitchDuration

onready var audio_streams_array = $Sounds.get_children()

export var oneshot : bool = false 
export var autostart : bool = false

export var sound_volume : float = 0.0

export var avg_cool_down : float = 4.5
export var cool_down_variance : float = 0.5

export var duration : float = 0.5
export var duration_variance : float = 0.2

export var avg_displace : float = 65.0
export var displace_variance : float = 35.0

export var avg_aberation : float = 0.0
export var aberation_variance : float = 20.0

export var avg_sub_glitch_duration : float = 0.075
export var sub_glitch_duration_variance : float = 0.025

var glitch : bool = false

signal glitch_started(dur)
signal glitch_finished

#### BUILT-IN ####

func _ready():
	var _err = glitch_timer_node.connect("timeout", self, "_on_glitch_duration_timeout")
	_err = sub_glitch_timer_node.connect("timeout", self, "_on_sub_glitch_duration_timeout")
	_err = glitch_cool_down.connect("timeout", self, "_on_cooldown_timeout")
	
	if autostart:
		start()


#### LOGIC ####


func start():
	glitch_cool_down.start()


func _generate_glitch():
	var shader_material = target_texture.get_material()
	
	# Play a random audio stream
	var stream_rng = randi() % len(audio_streams_array)
	audio_streams_array[stream_rng].play()
	
	var displace_amount = avg_displace + rand_range(0.0, displace_variance) * Math.rand_sign()
	var aberation_amount = avg_aberation + rand_range(0.0, aberation_variance) * Math.rand_sign()
	var sub_glitch_dur = avg_sub_glitch_duration + rand_range(0.0, sub_glitch_duration_variance) * Math.rand_sign()
	
	shader_material.set_shader_param("apply", true)
	shader_material.set_shader_param("displace_amount", displace_amount * Math.rand_sign())
	shader_material.set_shader_param("aberation_amount", aberation_amount)
	
	sub_glitch_timer_node.set_wait_time(sub_glitch_dur)
	sub_glitch_timer_node.start()


#### SIGNAL RESPONSES ####


func _on_glitch_duration_timeout():
	glitch_timer_node.stop()
	sub_glitch_timer_node.stop()
	var shader_material = target_texture.get_material()
	shader_material.set_shader_param("apply", false)
	
	if !oneshot:
		glitch_cool_down.set_wait_time(rand_range(avg_cool_down - cool_down_variance, avg_cool_down + cool_down_variance))
		glitch_cool_down.start()

	emit_signal("glitch_finished")


func _on_sub_glitch_duration_timeout():
	_generate_glitch()


func _on_cooldown_timeout():
	var dur = duration + rand_range(0.0, duration_variance) * Math.rand_sign()
	glitch_timer_node.set_wait_time(dur)
	glitch_timer_node.start()
	
	emit_signal("glitch_started", dur)
	
	_generate_glitch()
