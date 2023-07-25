class_name ProcessAirborne extends OnFrame

func _execute(inFt: Fighter, allowControl: bool = true):
	var tempInput = inFt.input_controller.get_movement_vector_unbuffered()
	
	if allowControl:
		if absf(tempInput.x) >= 0.01:
			var desiredSpeed = inFt.FightTable.MaxAerialHorizontalSpeed * absf(tempInput.x)
			inFt.ftVel.x = move_toward(inFt.ftVel.x, desiredSpeed * sign(tempInput.x), inFt.FightTable.AerialAcceleration)
		else:
			inFt.apply_drag()
	else:
			inFt.apply_drag()
	
	inFt.ftVel.y = maxf(inFt.ftVel.y - inFt.FightTable.Gravity, -inFt.FightTable.TerminalVelocity)
