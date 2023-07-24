class_name ProcessGrounded extends OnFrame

## Even if the player is applying input, apply traction.
@export var AlwaysApplyTraction: bool = false

func _execute(inFt: Fighter):
	inFt.ftVel.y = 0
	inFt.jumps = 0
	var tempInput = inFt.input_controller.get_movement_vector_unbuffered()
	var convInput = Vector3(tempInput.x, -tempInput.y, 0)
	if inFt.get_frame_in_state() < inFt.InterruptableTime or AlwaysApplyTraction:
		inFt.apply_traction()
	else: if absf(convInput.x) < 0.01:
		inFt.apply_traction()
