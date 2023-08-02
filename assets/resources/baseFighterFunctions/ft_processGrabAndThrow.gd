class_name ProcessGrabAndThrow extends OnFrame

func _execute(inFt: Fighter) -> void:
	inFt.FighterSkeleton.set_bone_pose_position(inFt.FighterSkeleton.find_bone("TransN"), Vector3.ZERO)
	inFt.FighterSkeleton.set_bone_pose_rotation(inFt.FighterSkeleton.find_bone("TransN"), Quaternion.IDENTITY)
	inFt.FighterSkeleton.set_bone_pose_scale(inFt.FighterSkeleton.find_bone("TransN"), Vector3.ONE)
	inFt.update_pose()
	if inFt.GrabbedFighter == -1:
		return
	var grabbed = inFt.stage.fighters[inFt.GrabbedFighter]
	var desiredHipPose : Transform3D = inFt.FighterSkeleton.get_bone_global_pose(inFt.FighterSkeleton.find_bone("ThrowN"))
	desiredHipPose = inFt.FighterSkeleton.transform * desiredHipPose
	desiredHipPose = inFt.transform * desiredHipPose
	var grabbedHipNGlobalPose : Transform3D = grabbed.FighterSkeleton.get_bone_global_pose(grabbed.FighterSkeleton.find_bone("HipN"))
	grabbedHipNGlobalPose = grabbed.FighterSkeleton.transform * grabbedHipNGlobalPose
	grabbedHipNGlobalPose = grabbed.transform * grabbedHipNGlobalPose
	var grabbedTransNGlobalPose : Transform3D = grabbed.FighterSkeleton.get_bone_global_pose(grabbed.FighterSkeleton.find_bone("TransN"))
	grabbedTransNGlobalPose = grabbed.FighterSkeleton.transform * grabbedTransNGlobalPose
	grabbedTransNGlobalPose = grabbed.transform * grabbedTransNGlobalPose
	var offset = desiredHipPose * (grabbedHipNGlobalPose.affine_inverse() * grabbedTransNGlobalPose)
	grabbed.ftPos = FHelp.Vec3to2(offset.origin)
	grabbed.FighterSkeleton.set_bone_global_pose_override(grabbed.FighterSkeleton.find_bone("TransN"), Transform3D(inFt.FighterSkeleton.get_bone_global_pose(inFt.FighterSkeleton.find_bone("ThrowN")).basis.orthonormalized(), Vector3.ZERO), 1, false)
	grabbed.update_pose()
