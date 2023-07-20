class_name TiltInterrupts extends Interrupt

var tiltInputTests = [[Vector2(1, 0), "AttackS3S"], [Vector2(0, -1), "AttackHi3"], [Vector2(0, 1), "AttackLw3"]]

func _execute(inFt: Fighter) -> bool:
	var inp = inFt.input_controller.get_movement_vector_unbuffered()
	inp.x *= inFt.facing
	var inpn = inp.normalized()
	var atk = inFt.input_controller.attack_pressed()
	var threshold = 0.1
	var desiredTilt
	for i in range(tiltInputTests.size()):
		var curTest = tiltInputTests[i]
		var dot1 = inpn.dot(curTest[0])
		var use = dot1 > sqrt(0.5) and inp.length() > threshold and atk
		if use:
			desiredTilt = curTest[1]
	if desiredTilt:
		inFt._change_fighter_state(inFt.find_state_by_name(desiredTilt), 0, 0)
		return true
	return false
	
