class_name AerialAttackInterrupts extends Interrupt

var aerialInputTests = [[Vector2(1, 0), "AttackAirF"], [Vector2(-1, 0), "AttackAirB"], [Vector2(0, -1), "AttackAirHi"], [Vector2(0, 1), "AttackAirLw"]]

func _execute(inFt: Fighter) -> bool:
	var inp = inFt.input_controller.get_movement_vector()
	var cst = inFt.input_controller.get_cstick_vector()
	inp.x *= inFt.facing
	cst.x *= inFt.facing
	var inpn = inp.normalized()
	var cstn = cst.normalized()
	var atk = inFt.input_controller.attack_pressed()
	var threshold = 0.75
	var desiredAerial
	for i in range(aerialInputTests.size()):
		var curTest = aerialInputTests[i]
		var dot1 = inpn.dot(curTest[0])
		var dot2 = cstn.dot(curTest[0])
		var use = (dot1 > sqrt(0.5) and inp.length() > threshold and atk) or (dot2 > sqrt(0.5) and cst.length() > threshold)
		if use:
			desiredAerial = curTest[1]
	if desiredAerial:
		inFt.set_fighter_flag(1, true)
		inFt._change_fighter_state(inFt.find_state_by_name(desiredAerial), 0, 0)
		return true
	if atk:
		inFt.set_fighter_flag(1, true)
		inFt._change_fighter_state(inFt.find_state_by_name("AttackAirN"), 0, 0)
		return true
	return false
