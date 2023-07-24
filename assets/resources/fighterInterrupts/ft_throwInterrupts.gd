class_name ThrowInterrupts extends Interrupt

var throwInputTests = [[Vector2(1, 0), "ThrowF"], [Vector2(0, -1), "ThrowHi"], [Vector2(0, 1), "ThrowLw"], [Vector2(-1, 0), "ThrowB"]]

func _execute(inFt: Fighter) -> bool:
	var inpx = inFt.input_controller.get_movement_vector_velocity_recent_highest("x")
	var inpy = inFt.input_controller.get_movement_vector_velocity_recent_highest("y")
	var inp = Vector2(inpx, inpy)
	var allow = inp.dot(inFt.input_controller.get_movement_vector_unbuffered()) >= 0.5
	if !allow:
		return false
	inp.x *= inFt.facing
	var inpn = inp.normalized()
	var threshold = 0.5
	var desiredThrow
	for i in range(throwInputTests.size()):
		var curTest = throwInputTests[i]
		var dot1 = inpn.dot(curTest[0])
		var use = (dot1 > sqrt(0.5) and inp.length() > threshold and inFt.input_controller.get_movement_vector_unbuffered().length() > threshold)
		if use:
			desiredThrow = curTest
	if desiredThrow:
		var clear = desiredThrow[0]
		clear.x *= inFt.facing
		inFt.input_controller.clear_movement_vector_velocity_above_threshold(clear)
		inFt._change_fighter_state(inFt.find_state_by_name(desiredThrow[1]), 0, 0)
		return true
	return false
	
