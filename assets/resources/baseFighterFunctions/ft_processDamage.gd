class_name ProcessDamage extends OnFrame

var AirMovement = preload("res://assets/resources/baseFighterFunctions/ft_processAirborne.tres")
var GroundMovement = preload("res://assets/resources/baseFighterFunctions/ft_processGrounded.tres")

func _execute(inFt: Fighter):
	if inFt.hitStun > 0:
		inFt.InterruptableTime = 32768
		if inFt.grounded and inFt.kbVel.y >= 0:
			GroundMovement._execute(inFt)
		else:
			AirMovement._execute(inFt, false)
	else:
		inFt.InterruptableTime = 0
		if inFt.get_frame_in_state() >= inFt.Animator.current_animation_length * 60:
			if inFt.grounded:
				inFt._change_fighter_state(inFt.find_state_by_name("Wait"), 0, 0)
			else:
				inFt._change_fighter_state(inFt.find_state_by_name("Fall"), 4, 0)
	if inFt.grounded:
		GroundMovement._execute(inFt)
	else:
		if inFt.hitStun > 0:
			AirMovement._execute(inFt, false)
		else:
			AirMovement._execute(inFt, true)
