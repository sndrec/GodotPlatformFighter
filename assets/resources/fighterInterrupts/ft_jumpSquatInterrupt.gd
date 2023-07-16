class_name JumpSquatInterrupt extends Interrupt

func _execute(inFt: Fighter) -> bool:
	var tempInput = inFt.input_controller.get_movement_vector()
	var convInput = Vector3(tempInput.x, -tempInput.y, 0)
	if convInput.y > 0.75 or inFt.input_controller.jump_pressed():
		inFt._change_fighter_state(inFt.find_state_by_name("JumpSquat"), blendTime)
		return true
	return false
