class_name AerialAttackLanding extends LandingFunc

@export var desiredState : String = "LandingAirN"

var regularLanding = preload("res://assets/resources/onLandingFunctions/regular_landing.tres")

func _execute(inFt: Fighter) -> void:
	if !inFt.check_fighter_flag(1):
		inFt.set_fighter_flag(12, false)
		inFt._change_fighter_state(inFt.find_state_by_name(desiredState), 0, 0)
	else:
		regularLanding._execute(inFt)
