class_name ProcessDamageFall extends OnFrame

var AirMovement = preload("res://assets/resources/baseFighterFunctions/ft_processAirborne.tres")

func _execute(inFt: Fighter) -> void:
	var downDesireBase = (inFt.get_frame_in_state() - 7) % 30
	if downDesireBase < 15:
		inFt.downDesire = "D"
	else:
		inFt.downDesire = "U"
	AirMovement._execute(inFt, true)
