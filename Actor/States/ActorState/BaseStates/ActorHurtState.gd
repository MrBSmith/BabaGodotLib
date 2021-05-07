extends ActorStateBase
class_name ActorHurtState

func enter_state():
	owner.tween.flash(Color.red)
	yield(owner.tween, "flash_finished")
	
	states_machine.set_state("Idle")


func exit_state():
	owner.emit_signal("hurt_animation_finished")
