class_name ProcessAerialAttack extends OnFrame

## State the fighter should enter when landing on the ground.
@export var landingLagState: String = "LandingAirN"

func _execute(inFt: Fighter) -> void:
	if inFt.grounded and !inFt.check_fighter_flag(1):
		inFt._change_fighter_state(inFt.find_state_by_name(landingLagState), 0, 0)
