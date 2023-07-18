class_name RunInterrupt extends Interrupt

func _execute(inFt: Fighter) -> bool:
	var tempInput = inFt.input_controller.get_movement_vector()
	var convInput = Vector3(tempInput.x, -tempInput.y, 0)
	if absf(convInput.x) >= 0.75 and inFt.check_fighter_flag(0) and sign(convInput.x) == inFt.facing:
		inFt._change_fighter_state(inFt.find_state_by_name("Run"), blendTime, lagTime)
		return true
	return false
