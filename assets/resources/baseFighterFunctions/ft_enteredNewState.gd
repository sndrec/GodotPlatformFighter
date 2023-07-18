class_name EnteredNewState extends FighterFunction

func _execute(inFt: Fighter):
	inFt.clear_hitboxes()
	inFt.unfold_action(inFt.charState.action)
	var hasAnim = inFt.charState.stateAnim != ""
	if inFt.facing == -1:
		inFt.rotation = Vector3(0, PI, 0)
	else:
		inFt.rotation = Vector3.ZERO
	
	if hasAnim:
		inFt.Animator.current_animation = inFt.charState.stateAnim
		inFt.Animator.assigned_animation = inFt.charState.stateAnim
		inFt.Animator.seek(0, true)
		inFt.update_pose()
