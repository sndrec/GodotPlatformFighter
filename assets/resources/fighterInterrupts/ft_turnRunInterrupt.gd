class_name TurnRunInterrupt extends Interrupt

func _execute(inFt: Fighter) -> bool:
	var inp = inFt.input_controller.get_movement_vector_unbuffered()
	if sign(inp.x) != inFt.facing and abs(inp.x) > 0.8:
		inFt._change_fighter_state(inFt.find_state_by_name("TurnRun"), blendTime, lagTime)
		return true
	return false
