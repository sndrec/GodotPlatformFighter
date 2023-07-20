class_name DashAttackInterrupt extends Interrupt

func _execute(inFt: Fighter) -> bool:
	var mx = inFt.input_controller.get_movement_vector_unbuffered().x
	if inFt.input_controller.attack_pressed() and absf(mx) > 0.9 and sign(mx) == inFt.facing:
		inFt.input_controller.clear_attack_pressed()
		inFt._change_fighter_state(inFt.find_state_by_name("AttackDash"), blendTime, lagTime)
		return true
	return false
