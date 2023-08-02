class_name RunBrakeInterrupt extends Interrupt

func _execute(inFt: Fighter) -> bool:
	var inp = inFt.input_controller.get_movement_vector_unbuffered()
	if abs(inp.x) < 0.15:
		inFt._change_fighter_state(inFt.find_state_by_name("RunBrake"), blendTime, lagTime)
		return true
	return false
