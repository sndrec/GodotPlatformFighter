class_name ProcessLandingLag extends FighterFunction

@export var landingLagFrames: int = 25
@export var endingState: String = "Wait"

func _execute(inFt: Fighter) -> void:
	inFt.InterruptableTime = landingLagFrames
	var lagLength = inFt.Animator.current_animation_length
	var timeTilCompletion = inFt.get_frame_in_state() / float(landingLagFrames)
	inFt.Animator.seek(lerpf(0, lagLength, timeTilCompletion), true)
	inFt.update_pose()
	if inFt.get_frame_in_state() > landingLagFrames:
		inFt._change_fighter_state(inFt.find_state_by_name(endingState))
