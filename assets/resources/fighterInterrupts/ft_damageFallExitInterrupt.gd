class_name DamageFallExitInterrupt extends Interrupt

func _execute(inFt: Fighter) -> bool:
	if inFt.input_controller.get_movement_vector_velocity_unbuffered().length() > 0.5:
		if inFt.jumps >= 2:
			inFt._change_fighter_state(inFt.find_state_by_name("FallAerial"), 8, 0)
		else:
			inFt._change_fighter_state(inFt.find_state_by_name("Fall"), 8, 0)
		return true
	return false
