class_name FastFallInterrupt extends Interrupt

func _execute(inFt: Fighter) -> bool:
	var recentHighestYVel = inFt.input_controller.get_movement_vector_velocity_recent_highest("y")
	var recentHighestY = inFt.input_controller.get_movement_vector_recent_highest("y")
	
	if inFt.check_fighter_flag(12) == false and inFt.ftVel.y <= 0 and recentHighestYVel > 0.6 and recentHighestY > 0.85:
		inFt.input_controller.clear_movement_vector_velocity_axis_above_threshold("y", 0.6)
		inFt.input_controller.clear_movement_vector_axis_above_threshold("y", 0.85)
		inFt.ftVel.y = -inFt.FightTable.FastFallTerminalVelocity
		inFt.set_fighter_flag(12, true)
	return false
