class_name ProcessDamageFly extends FighterFunction

var AirMovement = preload("res://assets/resources/baseFighterFunctions/ft_processAirborne.tres")

func _execute(inFt: Fighter):
	if inFt.hitStun > 0:
		inFt.InterruptableTime = 32768
		if inFt.grounded:
			inFt._change_fighter_state(inFt.find_state_by_name("DownBound"), 4, 0)
		else:
			AirMovement._execute(inFt, false)
	else:
		inFt.InterruptableTime = 0
		if inFt.grounded:
			inFt._change_fighter_state(inFt.find_state_by_name("DownBound"), 4, 0)
		else:
			AirMovement._execute(inFt, true)
