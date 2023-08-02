class_name ProcessRunMovement extends OnFrame

func _execute(inFt: Fighter):
	var tempInput = inFt.input_controller.get_movement_vector_unbuffered()
	if absf(tempInput.x) >= 0.75 and sign(tempInput.x) == inFt.facing:
		var desiredSpeed = maxf(inFt.FightTable.InitialRunSpeed * absf(tempInput.x), inFt.FightTable.InitialRunSpeed)
		inFt.ftVel.x = move_toward(inFt.ftVel.x, desiredSpeed * sign(tempInput.x), inFt.FightTable.RunAcceleration)
