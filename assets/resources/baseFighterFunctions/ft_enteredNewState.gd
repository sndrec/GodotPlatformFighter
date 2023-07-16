class_name EnteredNewState extends FighterFunction

func _execute(inFt: Fighter):
	inFt.clear_hitboxes()
	
	if inFt.facing == -1:
		inFt.rotation = Vector3(0, PI, 0)
	else:
		inFt.rotation = Vector3.ZERO
	
	inFt.Animator.current_animation = inFt.charState.stateAnim
	inFt.Animator.assigned_animation = inFt.charState.stateAnim
	inFt.Animator.seek(0, true)
	inFt.unfold_action(inFt.charState.action)
	#inFt.lastStateChange = inFt.input_controller.curTick
	inFt.TransNPhysics = inFt.charState.useAnimPhysics

	for i in range(inFt.FighterSkeleton.get_bone_count()):
		inFt.FighterSkeleton.force_update_bone_child_transform(i)
	
	if inFt.blendTime > 0:
		var ratio = float(inFt.get_frame_in_state() + 1) / inFt.blendTime
		for i in range(inFt.FighterSkeleton.get_bone_count()):
			var blendTransform = inFt.oldPose[i].interpolate_with(inFt.FighterSkeleton.get_bone_pose(i), ratio)
			inFt.FighterSkeleton.set_bone_pose_position(i, blendTransform.origin)
			inFt.FighterSkeleton.set_bone_pose_rotation(i, blendTransform.basis.get_rotation_quaternion())
			inFt.FighterSkeleton.set_bone_pose_scale(i, blendTransform.basis.get_scale())
			inFt.FighterSkeleton.force_update_bone_child_transform(i)
	
	var TransN = inFt.FighterSkeleton.find_bone("TransN")
	var TransNNewTransform = inFt.FighterSkeleton.get_bone_global_pose(TransN)
	var TransNPos = inFt.FighterSkeleton.to_global(TransNNewTransform.origin)
	TransNPos -= inFt.position
	inFt.TransNOldPos = TransNPos
