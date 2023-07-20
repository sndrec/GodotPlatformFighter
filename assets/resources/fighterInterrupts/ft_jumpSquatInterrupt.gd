class_name JumpSquatInterrupt extends Interrupt

func _execute(inFt: Fighter) -> bool:
	if inFt.charState.stateName == "JumpSquat":
		return false
	var tempInput = inFt.input_controller.get_movement_vector_unbuffered()
	var convInput = Vector3(tempInput.x, -tempInput.y, 0)
	if inFt.input_controller.jump_pressed():
		inFt.input_controller.clear_jump_pressed()
		inFt._change_fighter_state(inFt.find_state_by_name("JumpSquat"), blendTime, lagTime)
		return true
	return false
