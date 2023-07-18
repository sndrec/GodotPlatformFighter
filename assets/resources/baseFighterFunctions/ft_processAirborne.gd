class_name ProcessAirborne extends FighterFunction

func _execute(inFt: Fighter, allowControl: bool = true):
	if inFt.grounded:
		if inFt.ftVel.y > -0.1:
			inFt._change_fighter_state(inFt.find_state_by_name("Wait"), 8, 0)
		else:
			inFt._change_fighter_state(inFt.find_state_by_name("Landing"), 0, inFt.FightTable.NormalLandingLag)
	
	var tempInput = inFt.input_controller.get_movement_vector()
	var convInput = Vector3(tempInput.x, -tempInput.y, 0)
	
	if allowControl:
		if absf(convInput.x) >= 0.01:
			var desiredSpeed = inFt.FightTable.MaxAerialHorizontalSpeed * absf(convInput.x)
			inFt.ftVel.x = move_toward(inFt.ftVel.x, desiredSpeed * sign(convInput.x), inFt.FightTable.AerialSpeed)
		else:
			inFt.apply_drag()
	else:
			inFt.apply_drag()
	
	var terminalVelocity = -inFt.FightTable.TerminalVelocity
	if inFt.check_fighter_flag(12):
		terminalVelocity = -inFt.FightTable.FastFallTerminalVelocity
	inFt.ftVel.y = maxf(inFt.ftVel.y - inFt.FightTable.Gravity, -inFt.FightTable.TerminalVelocity)
	
	if allowControl and inFt.ftVel.y <= 0 and convInput.y <= -0.75:
		inFt.ftVel.y = -inFt.FightTable.FastFallTerminalVelocity
		inFt.set_fighter_flag(12, true)
