class_name ThrowInterrupts extends Interrupt

var throwInputTests = [[Vector2(1, 0), "ThrowF"], [Vector2(0, -1), "ThrowHi"], [Vector2(0, 1), "ThrowLw"], [Vector2(-1, 0), "ThrowB"]]

func _execute(inFt: Fighter) -> bool:
	var inp = inFt.input_controller.get_movement_vector_unbuffered()
	inp.x *= inFt.facing
	var inpn = inp.normalized()
	var threshold = 0.75
	var desiredThrow
	for i in range(throwInputTests.size()):
		var curTest = throwInputTests[i]
		var dot1 = inpn.dot(curTest[0])
		var use = (dot1 > sqrt(0.5) and inp.length() > threshold)
		if use:
			desiredThrow = curTest[1]
	if desiredThrow:
		inFt._change_fighter_state(inFt.find_state_by_name(desiredThrow), 0, 0)
		return true
	return false
	
