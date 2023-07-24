class_name JumpSquatInterrupt extends Interrupt

func _execute(inFt: Fighter) -> bool:
	if inFt.charState.stateName == "JumpSquat":
		return false
	if inFt.input_controller.jump_pressed():
		inFt.input_controller.clear_jump_pressed()
		inFt._change_fighter_state(inFt.find_state_by_name("JumpSquat"), blendTime, lagTime)
		return true
	return false
