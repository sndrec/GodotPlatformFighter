class_name DashInterrupt extends Interrupt

func _execute(inFt: Fighter) -> bool:
	var tempInput = inFt.input_controller.get_movement_vector_unbuffered()
	var inputVelocity = inFt.input_controller.get_movement_vector_velocity_unbuffered()
	var bufferedCheck2 = inFt.input_controller.get_movement_vector_velocity_recent_highest("x")
	if absf(tempInput.x) > 0.75 and absf(bufferedCheck2) > 0.4:
		if sign(tempInput.x) == inFt.facing:
			if inFt.charState.stateName == "Dash":
				return false
		else:
			inFt.facing *= -1
		inFt.input_controller.clear_movement_vector_velocity_axis_above_threshold("x", 0.4 * sign(bufferedCheck2))
		inFt._change_fighter_state(inFt.find_state_by_name("Dash"), blendTime, lagTime)
		return true
	return false
