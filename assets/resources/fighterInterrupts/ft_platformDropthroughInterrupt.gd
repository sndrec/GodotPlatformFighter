class_name PlatformDropthroughInterrupt extends Interrupt

func _execute(inFt: Fighter) -> bool:
	if !inFt.currentGround:
		return false
	if inFt.currentGround.colType != StageCollisionSegment.collisionType.semisolid:
		return false
	var inp : float = inFt.input_controller.get_movement_vector_recent_highest("y")
	var inpv : float = inFt.input_controller.get_movement_vector_velocity_recent_highest("y")
	if inp > 0.75 and inpv > 0.4:
		inFt.grounded = false
		inFt.input_controller.clear_movement_vector_axis_above_threshold("y", 0.75)
		inFt.input_controller.clear_movement_vector_velocity_axis_above_threshold("y", 0.4)
		inFt.ftPos += Vector2(0, -inFt.FightTable.Gravity)
		inFt._calculate_ecb(true)
		inFt._change_fighter_state(inFt.find_state_by_name("Dropthrough"), blendTime, lagTime)
		return true
	return false
