class_name ProcessLedgeState extends OnFrame

func _execute(inFt: Fighter) -> void:
	var TransN = inFt.FighterSkeleton.find_bone("TransN")
	var TransNNewTransform = inFt.FighterSkeleton.get_bone_global_pose(TransN)
	var offsetFromLedge = FHelp.Vec3to2(inFt.FighterSkeleton.to_global(TransNNewTransform.origin))
	offsetFromLedge -= inFt.ftPos
	inFt.ftPos = inFt.currentLedge.pos + offsetFromLedge
	inFt.ftVel = Vector2.ZERO
	inFt.FighterSkeleton.set_bone_pose_position(TransN, Vector3.ZERO)
	inFt.FighterSkeleton.set_bone_pose_rotation(TransN, Quaternion.IDENTITY)
	inFt.FighterSkeleton.set_bone_pose_scale(TransN, Vector3.ONE)
