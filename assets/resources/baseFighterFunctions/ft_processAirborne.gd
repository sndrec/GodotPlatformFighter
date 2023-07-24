class_name ProcessAirborne extends OnFrame

func _execute(inFt: Fighter, allowControl: bool = true):
	var tempInput = inFt.input_controller.get_movement_vector_unbuffered()
	var convInput = Vector3(tempInput.x, -tempInput.y, 0)
	
	if allowControl:
		if absf(convInput.x) >= 0.01:
			var desiredSpeed = inFt.FightTable.MaxAerialHorizontalSpeed * absf(convInput.x)
			inFt.ftVel.x = move_toward(inFt.ftVel.x, desiredSpeed * sign(convInput.x), inFt.FightTable.AerialAcceleration)
		else:
			inFt.apply_drag()
	else:
			inFt.apply_drag()
	
	inFt.ftVel.y = maxf(inFt.ftVel.y - inFt.FightTable.Gravity, -inFt.FightTable.TerminalVelocity)
	
	if allowControl and inFt.ftVel.y <= 0 and convInput.y <= -0.75:
		inFt.ftVel.y = -inFt.FightTable.FastFallTerminalVelocity
		inFt.set_fighter_flag(12, true)
