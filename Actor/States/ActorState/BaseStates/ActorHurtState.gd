extends TRPG_ActorStateBase
class_name ActorHurtState

signal hurt_feedback_finished

var animation_finished = false
var flash_finished = false


func enter_state():
	animation_finished = false
	flash_finished = false
	
	var tween = owner.tween
	var __ = tween.connect("flash_finished", self, "_on_flash_finished")
	__ = connect("hurt_feedback_finished", self, "_on_hurt_feedback_finished")
	
	owner.tween.flash(Color.red)
	.enter_state()


func exit_state():
	owner.tween.disconnect("flash_finished", self, "_on_flash_finished")
	disconnect("hurt_feedback_finished", self, "_on_hurt_feedback_finished")


#### SIGNAL RESPONSES ####


func _on_state_animation_finished() -> void:
	animation_finished = true
	
	if animation_finished && flash_finished:
		emit_signal("hurt_feedback_finished")


func _on_flash_finished() -> void:
	flash_finished = true
	
	if animation_finished && flash_finished:
		emit_signal("hurt_feedback_finished")


func _on_hurt_feedback_finished() -> void:
	if toggle_state_mode:
		states_machine.set_state(states_machine.previous_state)
