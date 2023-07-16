class_name ProcessWalkMovement extends FighterFunction

func _execute(inFt: Fighter):
	var tempInput = inFt.input_controller.get_movement_vector()
	var convInput = Vector3(tempInput.x, -tempInput.y, 0)
	if inFt.facing == 1:
		convInput.x = max(convInput.x, 0)
	else:
		convInput.x = min(convInput.x, 0)
	if absf(convInput.x) >= 0.01:
		var desiredSpeed = maxf(inFt.FightTable.MaxWalkSpeed * absf(convInput.x), inFt.FightTable.InitialWalkSpeed)
		inFt.ftVel.x = move_toward(inFt.ftVel.x, desiredSpeed * sign(convInput.x), inFt.FightTable.WalkAcceleration)
