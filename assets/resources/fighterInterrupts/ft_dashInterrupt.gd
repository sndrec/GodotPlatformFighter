class_name DashInterrupt extends Interrupt

func _execute(inFt: Fighter) -> bool:
	var tempInput = inFt.input_controller.get_movement_vector()
	var inputVelocity = inFt.input_controller.get_movement_vector_velocity()
	if absf(tempInput.x) > 0.75 and absf(inputVelocity.x) > 0.4:
		if sign(tempInput.x) == inFt.facing and inFt.charState.stateName == "Dash":
			return false
		else:
			inFt.facing *= -1
		inFt._change_fighter_state(inFt.find_state_by_name("Dash"), blendTime, lagTime)
		return true
	return false
