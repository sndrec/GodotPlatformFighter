class_name SmashInterrupts extends Interrupt

var tiltInputTests = [[Vector2(1, 0), "AttackS4"], [Vector2(0, -1), "AttackHi4"], [Vector2(0, 1), "AttackLw4"]]

func _execute(inFt: Fighter) -> bool:
	var inp = inFt.input_controller.get_movement_vector_unbuffered()
	var cst = inFt.input_controller.get_cstick_vector_unbuffered()
	var inpv = inFt.input_controller.get_movement_vector_velocity_unbuffered()
	inp.x *= inFt.facing
	cst.x *= inFt.facing
	inpv.x *= inFt.facing
	var inpn = inp.normalized()
	var cstn = cst.normalized()
	var atk = inFt.input_controller.attack_pressed()
	var threshold = 0.75
	var desiredTilt
	for i in range(tiltInputTests.size()):
		var curTest = tiltInputTests[i]
		var dot1 = inpn.dot(curTest[0])
		var dot2 = cstn.dot(curTest[0])
		var dot3 = inpv.dot(curTest[0])
		var use = (dot1 > sqrt(0.5) and inp.length() > threshold and atk and dot3 > 0.5) or (dot2 > sqrt(0.5) and cst.length() > threshold)
		if use:
			desiredTilt = curTest[1]
	if desiredTilt:
		inFt.input_controller.clear_attack_pressed()
		inFt._change_fighter_state(inFt.find_state_by_name(desiredTilt), 0, 0)
		return true
	return false
	
