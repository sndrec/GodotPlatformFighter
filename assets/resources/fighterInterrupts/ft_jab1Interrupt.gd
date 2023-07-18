class_name Jab1Interrupt extends Interrupt

func _execute(inFt: Fighter) -> bool:
	if inFt.input_controller.attack_pressed() and absf(inFt.input_controller.get_movement_vector().x) <= 0.05:
		inFt._change_fighter_state(inFt.find_state_by_name("Jab1"), blendTime, lagTime)
		return true
	return false
