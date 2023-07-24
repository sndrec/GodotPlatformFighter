class_name DamageFlyLanding extends LandingFunc

func _execute(inFt: Fighter) -> void:
	inFt._change_fighter_state(inFt.find_state_by_name("DownBound"), 4, 0)
