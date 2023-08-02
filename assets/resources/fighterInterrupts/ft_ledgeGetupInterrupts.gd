class_name LedgeGetupInterrupts extends Interrupt

func _execute(inFt: Fighter) -> bool:
	
	if inFt.input_controller.check_movement_vector_above(Vector2(0, 0.8)):
		#print(inFt.input_controller.get_movement_vector_unbuffered())
		inFt.input_controller.clear_movement_vector_above_threshold(Vector2(0, 0.8))
		inFt.ftVel.y = -inFt.FightTable.FastFallTerminalVelocity
		inFt.lastTimeOnLedge = inFt.internalFrameCounter
		inFt.set_fighter_flag(12, true)
		inFt._change_fighter_state(inFt.find_state_by_name("Fall"), blendTime, lagTime)
		return true
	var back = Vector2(-0.8, 0)
	back *= inFt.facing
	if inFt.input_controller.check_movement_vector_above(back):
		inFt.input_controller.clear_movement_vector_above_threshold(back)
		inFt.lastTimeOnLedge = inFt.internalFrameCounter
		inFt._change_fighter_state(inFt.find_state_by_name("Fall"), blendTime, lagTime)
		return true
	if inFt.input_controller.check_movement_vector_above(Vector2(0, -0.8)):
		inFt.input_controller.clear_movement_vector_above_threshold(Vector2(0, -0.8))
		inFt.lastTimeOnLedge = inFt.internalFrameCounter
		if inFt.percentage < 100:
			inFt._change_fighter_state(inFt.find_state_by_name("CliffClimbQuick"), blendTime, lagTime)
		else:
			inFt._change_fighter_state(inFt.find_state_by_name("CliffClimbSlow"), blendTime, lagTime)
		return true
	if inFt.input_controller.shield_pressed():
		inFt.input_controller.clear_shield_pressed()
		inFt.lastTimeOnLedge = inFt.internalFrameCounter
		if inFt.percentage < 100:
			inFt._change_fighter_state(inFt.find_state_by_name("CliffEscapeQuick"), blendTime, lagTime)
		else:
			inFt._change_fighter_state(inFt.find_state_by_name("CliffEscapeSlow"), blendTime, lagTime)
		return true
	if inFt.input_controller.attack_pressed():
		inFt.input_controller.clear_attack_pressed()
		inFt.lastTimeOnLedge = inFt.internalFrameCounter
		if inFt.percentage < 100:
			inFt._change_fighter_state(inFt.find_state_by_name("CliffAttackQuick"), blendTime, lagTime)
		else:
			inFt._change_fighter_state(inFt.find_state_by_name("CliffAttackSlow"), blendTime, lagTime)
		return true
	return false
