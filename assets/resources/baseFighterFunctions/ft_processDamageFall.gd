class_name ProcessDamageFall extends FighterFunction

var AirMovement = preload("res://assets/resources/baseFighterFunctions/ft_processAirborne.tres")

func _execute(inFt: Fighter) -> void:
	var downDesireBase = (inFt.get_frame_in_state() - 7) % 30
	if downDesireBase < 15:
		inFt.downDesire = "D"
	else:
		inFt.downDesire = "U"
	if inFt.grounded:
		inFt._change_fighter_state(inFt.find_state_by_name("DownBound"), 4, 0)
	else:
		AirMovement._execute(inFt, true)
