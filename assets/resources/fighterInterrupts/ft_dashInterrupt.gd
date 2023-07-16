class_name DashInterrupt extends Interrupt

func _execute(inFt: Fighter) -> bool:
	var tempInput = inFt.input_controller.get_movement_vector()
	var convInput = Vector3(tempInput.x, -tempInput.y, 0)
	var inputVelocity = inFt.input_controller.get_movement_vector_velocity()
	if absf(convInput.x) > 0.75 and absf(inputVelocity.x) > 0.4:
		if sign(convInput.x) == inFt.facing:
			if inFt.charState.stateName == "Dash":
				return false
		else:
			inFt.facing *= -1
		inFt._change_fighter_state(inFt.find_state_by_name("Dash"), blendTime)
		return true
	return false
