class_name ProcessAirDodge extends OnFrame

var AirMovement = preload("res://assets/resources/baseFighterFunctions/ft_processAirborne.tres")

func _execute(inFt: Fighter):
	if inFt.grounded:
		inFt._change_fighter_state(inFt.find_state_by_name("Landing"), 0, 10)
		return
	if inFt.get_frame_in_state() < 30:
		inFt.InterruptableTime = 32768
		inFt.ftVel = inFt.ftVel * 0.9
	else:
		AirMovement._execute(inFt)
		inFt.InterruptableTime = 0
