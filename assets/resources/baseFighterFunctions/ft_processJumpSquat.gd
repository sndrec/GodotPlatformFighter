class_name ProcessJumpSquat extends OnFrame

func _execute(inFt: Fighter):
	inFt.Animator.current_animation = inFt.charState.stateAnim
	inFt.Animator.assigned_animation = inFt.charState.stateAnim
	inFt.Animator.seek(0, true)
	inFt.FighterSkeleton.force_update_bone_child_transform(0)
	if absf(inFt.input_controller.get_movement_vector_unbuffered().x) >= 0.01:
		inFt.apply_traction()
