class_name WalkSlowInterrupt extends Interrupt

func _execute(inFt: Fighter) -> bool:
	var tempInput = inFt.input_controller.get_movement_vector()
	var convInput = Vector3(tempInput.x, -tempInput.y, 0)
	if absf(convInput.x) >= 0.02 and absf(inFt.ftVel.x) < inFt.FightTable.MidWalkPoint:
		inFt._change_fighter_state(inFt.find_state_by_name("WalkSlow"), blendTime, lagTime)
		return true
	return false
