class_name JumpInterrupt extends Interrupt

func _execute(inFt: Fighter) -> bool:
	if inFt.get_frame_in_state() >= inFt.FightTable.JumpStartupLag:
		inFt.grounded = false
		inFt.jumps += 1
		if inFt.input_controller.jump_down():
			inFt.ftVel.y = inFt.FightTable.InitialVerticalJumpVelocity
		else:
			inFt.ftVel.y = inFt.FightTable.MaximumShorthopVerticalVelocity
		inFt.set_fighter_flag(12, false)
		inFt.ftVel.x *= inFt.FightTable.GroundToAirJumpMomentumMultiplier
		if absf(inFt.ftVel.x) < inFt.FightTable.InitialHorizontalJumpVelocity or sign(inFt.input_controller.get_movement_vector().x) != inFt.facing:
			inFt.ftVel.x = inFt.FightTable.InitialHorizontalJumpVelocity * inFt.input_controller.get_movement_vector().x
		if sign(inFt.ftVel.x) == inFt.facing:
			inFt._change_fighter_state(inFt.find_state_by_name("JumpF"), blendTime, lagTime)
		else:
			inFt._change_fighter_state(inFt.find_state_by_name("JumpB"), blendTime, lagTime)
		return true
	return false
