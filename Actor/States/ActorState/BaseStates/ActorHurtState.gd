extends TRPG_ActorStateBase
class_name ActorHurtState

func enter_state():
	owner.tween.flash(Color.red)
	.enter_state()
