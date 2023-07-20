class_name DownInterrupt extends Interrupt

func _execute(inFt: Fighter) -> bool:
	var inp = inFt.input_controller.get_movement_vector_unbuffered()
	inp.x *= inFt.facing
	var up = inp.y < -0.85
	var forward = inp.x > 0.85
	var back = inp.x < -0.85
	var atk = inFt.input_controller.attack_pressed()
	if up:
		inFt._change_fighter_state(inFt.find_state_by_name("DownStand"), blendTime, lagTime)
		return true
	if forward:
		inFt._change_fighter_state(inFt.find_state_by_name("DownForward"), blendTime, lagTime)
		return true
	if back:
		inFt._change_fighter_state(inFt.find_state_by_name("DownBack"), blendTime, lagTime)
		return true
	if atk:
		inFt._change_fighter_state(inFt.find_state_by_name("DownAttack" + inFt.downDesire), blendTime, lagTime)
		return true
	return false
