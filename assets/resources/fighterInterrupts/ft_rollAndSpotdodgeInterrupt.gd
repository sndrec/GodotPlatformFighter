class_name RollAndSpotdodgeInterrupt extends Interrupt

var tiltInputTests = [[Vector2(1, 0), "EscapeF"], [Vector2(-1, 0), "EscapeB"], [Vector2(0, 1), "EscapeN"]]

func _execute(inFt: Fighter) -> bool:
	var cst = inFt.input_controller.get_cstick_vector_unbuffered()
	cst.x *= inFt.facing
	var cstn = cst.normalized()
	var threshold = 0.85
	var desiredTilt
	for i in range(tiltInputTests.size()):
		var curTest = tiltInputTests[i]
		var dot1 = cstn.dot(curTest[0])
		var use = (dot1 > sqrt(0.5) and cst.length() > threshold)
		if use:
			desiredTilt = curTest[1]
	if desiredTilt:
		inFt._change_fighter_state(inFt.find_state_by_name(desiredTilt), 0, 0)
		return true
	
	var inp = inFt.input_controller.get_movement_vector_unbuffered()
	var inpv = inFt.input_controller.get_movement_vector_velocity_unbuffered()
	inpv.x *= inFt.facing
	inp.x *= inFt.facing
	var inpvn = inpv.normalized()
	var inpn = inp.normalized()
	var threshold2 = 0.6
	var desiredTilt2
	for i in range(tiltInputTests.size()):
		var curTest = tiltInputTests[i]
		var dot1 = inpvn.dot(curTest[0])
		var use = (dot1 > sqrt(0.5) and inpv.length() > threshold2)
		var dot2 = inpn.dot(curTest[0])
		var use2 = (dot2 > sqrt(0.5) and inp.length() > threshold)
		if use and use2:
			desiredTilt2 = curTest[1]
	if desiredTilt2: 
		inFt._change_fighter_state(inFt.find_state_by_name(desiredTilt2), 0, 0)
		return true
	return false
	
