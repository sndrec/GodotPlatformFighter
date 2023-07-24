class_name RegularAirborne extends AirborneFunc

func _execute(inFt: Fighter) -> void:
	inFt.jumps = 1
	inFt._change_fighter_state(inFt.find_state_by_name("Fall"), 0, 0)
