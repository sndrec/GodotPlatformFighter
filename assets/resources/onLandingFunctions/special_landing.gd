class_name SpecialLanding extends LandingFunc

@export var LandingLag: int = 10

func _execute(inFt: Fighter) -> void:
	inFt.jumps = 0
	inFt.ftVel.y = 0
	inFt.set_fighter_flag(12, false)
	inFt._change_fighter_state(inFt.find_state_by_name("Landing"), 0, LandingLag)
