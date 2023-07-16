class_name TurnInterrupt extends Interrupt

func _execute(inFt: Fighter) -> bool:
	var tempInput = inFt.input_controller.get_movement_vector()
	var convInput = Vector3(tempInput.x, -tempInput.y, 0)
	if absf(convInput.x) >= 0.01 and sign(convInput.x) != inFt.facing:
		inFt._change_fighter_state(inFt.find_state_by_name("Turn"), blendTime)
		return true
	return false
