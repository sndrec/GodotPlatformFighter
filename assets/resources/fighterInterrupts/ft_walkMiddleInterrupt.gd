class_name WalkMiddleInterrupt extends Interrupt

func _execute(inFt: Fighter) -> bool:
	if inFt.charState.stateName == "WalkMiddle":
		return false
	var tempInput = inFt.input_controller.get_movement_vector_unbuffered()
	var convInput = Vector3(tempInput.x, -tempInput.y, 0)
	if absf(convInput.x) >= 0.01 and absf(inFt.ftVel.x) >= inFt.FightTable.MidWalkPoint and absf(inFt.ftVel.x) < inFt.FightTable.FastWalkSpeed:
		inFt._change_fighter_state(inFt.find_state_by_name("WalkMiddle"), blendTime, lagTime)
		return true
	return false
