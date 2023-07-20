class_name ProcessJumpSquat extends FighterFunction

func _execute(inFt: Fighter):
	inFt.Animator.current_animation = inFt.charState.stateAnim
	inFt.Animator.assigned_animation = inFt.charState.stateAnim
	inFt.Animator.seek(0, true)
	for i in range(inFt.FighterSkeleton.get_bone_count()):
		inFt.FighterSkeleton.force_update_bone_child_transform(i)
	if absf(inFt.input_controller.get_movement_vector_unbuffered().x) >= 0.01:
		inFt.apply_traction()
