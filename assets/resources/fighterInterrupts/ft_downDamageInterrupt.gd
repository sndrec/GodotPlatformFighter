class_name DownDamageInterrupt extends Interrupt

func _execute(inFt: Fighter) -> bool:
	if inFt.Animator.current_animation_position >= inFt.Animator.current_animation_length:
		var grounded = inFt.check_and_move_to_ground()
		if !grounded:
			inFt._change_fighter_state(inFt.find_state_by_name("Fall"), blendTime, lagTime)
		var inp = inFt.input_controller.get_movement_vector_unbuffered()
		inp.x *= inFt.facing
		if inp.x >= 0.8:
			inFt._change_fighter_state(inFt.find_state_by_name("DownForward"), blendTime, lagTime)
			return true
		if inp.x <= -0.8:
			inFt._change_fighter_state(inFt.find_state_by_name("DownBack"), blendTime, lagTime)
			return true
		if inFt.input_controller.attack_down():
			inFt._change_fighter_state(inFt.find_state_by_name("DownAttack" + inFt.downDesire), blendTime, lagTime)
			return true
		inFt._change_fighter_state(inFt.find_state_by_name("DownStand"), blendTime, lagTime)
		return true
	return false
