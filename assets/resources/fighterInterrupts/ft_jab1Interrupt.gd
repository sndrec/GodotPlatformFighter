class_name Jab1Interrupt extends Interrupt

func _execute(inFt: Fighter) -> bool:
	if inFt.charState.stateName == "Jab1":
		return false
	if inFt.input_controller.attack_pressed() and absf(inFt.input_controller.get_movement_vector_unbuffered().x) <= 0.05:
		inFt.input_controller.clear_attack_pressed()
		inFt._change_fighter_state(inFt.find_state_by_name("Jab1"), blendTime, lagTime)
		return true
	return false
