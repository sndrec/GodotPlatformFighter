class_name RegularLanding extends LandingFunc

func _execute(inFt: Fighter) -> void:
	inFt.jumps = 0
	if inFt.ftVel.y > -1:
		inFt.ftVel.y = 0
		inFt._change_fighter_state(inFt.find_state_by_name("Wait"), 8, 0)
	else:
		inFt.ftVel.y = 0
		inFt._change_fighter_state(inFt.find_state_by_name("Landing"), 0, 4)
