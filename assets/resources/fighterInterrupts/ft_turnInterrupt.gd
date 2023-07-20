class_name TurnInterrupt extends Interrupt

func _execute(inFt: Fighter) -> bool:
	if inFt.charState.stateName == "Turn":
		return false
	var tempInput = inFt.input_controller.get_movement_vector_unbuffered()
	if absf(tempInput.x) >= 0.1 and sign(tempInput.x) != inFt.facing:
		inFt._change_fighter_state(inFt.find_state_by_name("Turn"), blendTime, lagTime)
		return true
	return false
