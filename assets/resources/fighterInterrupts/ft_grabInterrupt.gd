class_name GrabInterrupt extends Interrupt

func _execute(inFt: Fighter) -> bool:
	if inFt.input_controller.grab_pressed():
		inFt.input_controller.clear_grab_pressed()
		inFt._change_fighter_state(inFt.find_state_by_name("Catch"), 4, 0)
		return true
	return false
