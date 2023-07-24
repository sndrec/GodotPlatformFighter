class_name ProcessRunMovement extends OnFrame

func _execute(inFt: Fighter):
	var tempInput = inFt.input_controller.get_movement_vector_unbuffered()
	var convInput = Vector3(tempInput.x, -tempInput.y, 0)
	if absf(convInput.x) >= 0.75:
		var desiredSpeed = maxf(inFt.FightTable.InitialRunSpeed * absf(convInput.x), inFt.FightTable.InitialRunSpeed)
		inFt.ftVel.x = move_toward(inFt.ftVel.x, desiredSpeed * sign(convInput.x), inFt.FightTable.WalkAcceleration)
