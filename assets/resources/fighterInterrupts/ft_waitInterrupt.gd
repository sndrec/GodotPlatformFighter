class_name WaitInterrupt extends Interrupt

func _execute(inFt: Fighter) -> bool:
	var tempInput = inFt.input_controller.get_movement_vector()
	var convInput = Vector3(tempInput.x, -tempInput.y, 0)
	if absf(inFt.ftVel.x) < inFt.FightTable.InitialWalkSpeed and absf(convInput.x) < 0.01:
		inFt._change_fighter_state(inFt.find_state_by_name("Wait"), blendTime)
		return true
	return false
