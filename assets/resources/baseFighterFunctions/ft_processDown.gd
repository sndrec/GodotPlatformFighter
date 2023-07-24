class_name ProcessDown extends OnFrame

func _execute(inFt: Fighter):
	if inFt.grounded:
		inFt.ftVel.y = 0
		inFt.jumps = 0
		inFt.apply_traction()
	else:
		if inFt.charState.stateName == "DownWait":
			inFt._change_fighter_state(inFt.find_state_by_name("Fall"), 4, 0)
		inFt.apply_drag()
		var terminalVelocity = -inFt.FightTable.TerminalVelocity
		inFt.ftVel.y = maxf(inFt.ftVel.y - inFt.FightTable.Gravity, -inFt.FightTable.TerminalVelocity)
