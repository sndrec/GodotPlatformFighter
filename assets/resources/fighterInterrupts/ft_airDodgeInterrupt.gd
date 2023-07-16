class_name AirDodgeInterrupt extends Interrupt

func _execute(inFt: Fighter) -> bool:
	if inFt.input_controller.shield_pressed():
		var tempInput = inFt.input_controller.get_movement_vector()
		var convInput = Vector2(tempInput.x, -tempInput.y)
		if convInput.length() > 1:
			convInput = convInput.normalized()
		var airDodgeStrength = 3
		inFt.ftVel = convInput * airDodgeStrength
		inFt._change_fighter_state(inFt.find_state_by_name("EscapeAir"))
		return true
	return false
