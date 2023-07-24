class_name ProcessDamageFly extends OnFrame

var AirMovement = preload("res://assets/resources/baseFighterFunctions/ft_processAirborne.tres")

func _execute(inFt: Fighter):
	if inFt.hitStun > 0:
		inFt.InterruptableTime = 32768
		AirMovement._execute(inFt, false)
	else:
		AirMovement._execute(inFt, true)
