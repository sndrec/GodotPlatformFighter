class_name DamageFlyInterrupt extends Interrupt

func _execute(inFt: Fighter) -> bool:
	if inFt.Animator.current_animation_position >= inFt.Animator.current_animation_length:
		inFt._change_fighter_state(inFt.find_state_by_name("DamageFall"), 4, 0)
		return true
	return false
