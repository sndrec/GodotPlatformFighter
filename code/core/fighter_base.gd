@tool

extends Node3D

class_name Fighter

var lastConstruct = 0.0
@onready var Animator: NetworkAnimationPlayer = $AnimationPlayer
@onready var FighterSkeleton: Skeleton3D = $Skeleton3D
var input_controller: BasePlayer
var stage: PFStage
var badgeGrid
@export var UpdateHurtboxes = false:
	set(inHurt):
		construct_hurtboxes()
		UpdateHurtboxes = inHurt

## Hurtboxes are what attack and grab hitboxes test against, to see if you should be hit.
## Try to match them closely to the shape of your character.
@export var Hurtboxes: Array[HurtboxDefinition] = []

## These are important properties, used to determine the characteristics of your fighter.
## You can control things such as movement speed and acceleration, weight, falling speed, and more.
@export var FightTable: Dictionary = {
	InitialWalkSpeed = 0.08,
	WalkAcceleration = 0.0,
	MaxWalkSpeed = 0.73,
	WalkAnimationSpeed = 1.0,
	MidWalkPoint = 0.445,
	FastWalkSpeed = 0.72,
	Friction = 0.07,
	InitialDashSpeed = 1.45,
	StopTurnInitialSpeedA = 0.08,
	StopTurnInitialSpeedB = 0.01,
	InitialRunSpeed = 1.5,
	RunAnimationScale = 1.0,
	DashDurationBeforeRunning = 3,
	JumpStartupLag = 5,
	InitialHorizontalJumpVelocity = 0.9,
	InitialVerticalJumpVelocity = 2.9,
	GroundToAirJumpMomentumMultiplier = 0.85,
	MaximumShorthopHorizontalVelocity = 1.8,
	MaximumShorthopVerticalVelocity = 2.0,
	VerticalAirJumpMultiplier = 0.95,
	HorizontalAirJumpMultiplier = 1.0,
	NumberOfJumps = 2,
	Gravity = 0.13,
	TerminalVelocity = 0.5,
	AerialSpeed = 0.046,
	AerialFriction = 0.02,
	MaxAerialHorizontalSpeed = 0.95,
	AirFriction = 0.02,
	FastFallTerminalVelocity = 2.7,
	FramesToChangeDirectionOnStandingTurn = 4,
	Weight = 109.0,
	ModelScale = 1.0,
	ShieldSize = 15.0,
	ShieldBreakInitialVelocity = 3.4,
	LedgeJumpHorizontalVelocity = 1.0,
	LedgeJumpVerticalVelocity = 3.4,
	NormalLandingLag = 4,
	NairLandingLag = 25,
	FairLandingLag = 25,
	BairLandingLag = 25,
	UairLandingLag = 25,
	DairLandingLag = 25,
	WallJumpHorizontalVelocity = 1.3,
	WallJumpVerticalVelocity = 2.6
}

## Names of the bones that should be used to calculate the ECB,
## a special structure used to create the character's collision.
## Recommended to select 3-6 bones that will typically represent
## the bounds of your character, like hands/feet/head/tail.
@export var ECB_Bones: Array[String] = []

## Function to run any time the fighter enters a new state.
## Args:
## inFighter: The fighter whose state is changing.
@export var OnStateEnterFuncs: Array[FighterFunction] = []

## Function to run on every frame.
## Args:
## inFighter: The fighter this function is being called on.
@export var OnFrameFuncs: Array[FighterFunction] = []

## Function to run when this fighter takes damage.[br]
## Args:[br]
## inFighter: The fighter being damaged.[br]
## inHurtbox: The hurtbox that was struck, belonging to the victim.[br]
## inHurtbox: The hitbox that struck the hurtbox, belonging to the attacker.[br]
## attacker: The fighter which hit the victim.
@export var OnDamageFuncs: Array[FighterFunction] = []

## All possible states for the fighter to exist in.
@export var States: Array[FighterState] = []

@export var shield: ShieldDefinition

var ourShield: ShieldDefinition
var ECB: Array = [[Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO], Vector2.ZERO]
var ECBOld: Array = [[Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO], Vector2.ZERO]
var ActiveHitboxes: Array[HitboxDefinition] = []
var curSubaction: Array[Array]
var stateFlags: int = 0
var FightersHit: Array[Fighter] = []
var facing = 1
var kbVel = Vector2.ZERO
var ftVel = Vector2.ZERO
var ftPos = Vector2.ZERO
var grounded = false
var hitLag = 0
var hitStun = 0
var percentage = 0.0
var charState: FighterState
var oldPose : Array[Transform3D] = []
var blendTime : int = 0
var lastStateChange = 0
var TransNPhysics = false
var TransNOldPos: Vector3 = Vector3.ZERO
var InterruptableTime = 0
var jumps : int = 0
var JustChangedState : bool = false
var internalFrameCounter : int = 0
var lastHitHurtbox : HurtboxDefinition
var lastHitHitbox : HitboxDefinition
var downDesire = "U"
var effectiveVel = Vector2.ZERO
var shieldStun = 0



func _ready():
	if Engine.is_editor_hint():
		construct_hurtboxes()

func check_fighter_flag(num: int) -> bool:
	var flag = 1 << num
	var bitAnd = stateFlags & flag
	return bitAnd > 0

func set_fighter_flag(num: int, inBool: bool) -> void:
	if check_fighter_flag(num) != inBool:
		var flag = 1 << num
		stateFlags = stateFlags ^ flag

func update_ui_percent() -> void:
	badgeGrid.update_player_percent(self)

func _network_spawn(data: Dictionary) -> void:
	position = data["position"]
	input_controller = data["controller"]
	ourShield = shield.duplicate()
	_change_fighter_state(States[0])

func respawn_self() -> void:
	percentage = 0
	ftPos = Vector2.ZERO
	kbVel = Vector2.ZERO
	_change_fighter_state(find_state_by_name("Wait"), 0, 0)
	_calculate_ecb(true)
	_calculate_ecb(true)
	update_ui_percent()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		if Time.get_unix_time_from_system() > lastConstruct + 0.01666 and UpdateHurtboxes:
			construct_hurtboxes()
			lastConstruct = Time.get_unix_time_from_system()

func clear_hitboxes() -> void:
	ActiveHitboxes.clear()
	FightersHit.clear()

func get_frame_in_state() -> int:
	return internalFrameCounter - lastStateChange

func get_shield_size() -> float:
	var shieldPos = FighterSkeleton.get_bone_global_pose(FighterSkeleton.find_bone("Extra"))
	var globalShieldPos = FighterSkeleton.to_global(shieldPos.origin)
	var shieldHealthRatio = ourShield.health / ourShield.maxHealth
	var shieldSizeHard = lerp(ourShield.endSizeHardShield, ourShield.startSizeHardShield, shieldHealthRatio)
	var shieldSizeLight = lerp(ourShield.endSizeLightShield, ourShield.startSizeLightShield, shieldHealthRatio)
	var triggerWithDeadzone = move_toward(input_controller.get_trigger_analog_unbuffered(), 0, 0.1) * 1.1111
	return lerp(shieldSizeLight, shieldSizeHard, triggerWithDeadzone)

func get_shield_position() -> Vector3:
	var shieldPos = FighterSkeleton.get_bone_global_pose(FighterSkeleton.find_bone("Extra"))
	return FighterSkeleton.to_global(shieldPos.origin)

func draw_ecb() -> void:
	var ECBOldBot = Vector3(0,0,0)
	var ECBOldLeft = Vector3(ECBOld[0][0].x, ECBOld[0][0].y,0)
	var ECBOldTop = Vector3(0, ECBOld[0][1].y,0)
	var ECBOldRight = Vector3(ECBOld[0][2].x, ECBOld[0][2].y,0)
	var oldPos = Vector3(ECBOld[1].x, ECBOld[1].y, 2)
	DebugDraw.draw_line(oldPos, oldPos + ECBOldLeft, Color(1, 0.25, 0, 1), 0.016666)
	DebugDraw.draw_line(oldPos + ECBOldLeft, oldPos + ECBOldTop, Color(1, 0.25, 0, 1), 0.016666)
	DebugDraw.draw_line(oldPos + ECBOldTop, oldPos + ECBOldRight, Color(1, 0.25, 0, 1), 0.016666)
	DebugDraw.draw_line(oldPos + ECBOldRight, oldPos + ECBOldBot, Color(1, 0.25, 0, 1), 0.016666)
	
	var ECBBot = Vector3(0,0,0)
	var ECBLeft = Vector3(ECB[0][0].x, ECB[0][0].y,0)
	var ECBTop = Vector3(0, ECB[0][1].y,0)
	var ECBRight = Vector3(ECB[0][2].x, ECB[0][2].y,0)
	var newPos = FHelp.Vec2to3(ftPos)
	DebugDraw.draw_line(newPos, newPos + ECBLeft, Color(1, 1, 0, 1), 0.016666)
	DebugDraw.draw_line(newPos + ECBLeft, newPos + ECBTop, Color(1, 1, 0, 1), 0.016666)
	DebugDraw.draw_line(newPos + ECBTop, newPos + ECBRight, Color(1, 1, 0, 1), 0.016666)
	DebugDraw.draw_line(newPos + ECBRight, newPos + ECBBot, Color(1, 1, 0, 1), 0.016666)

func _calculate_ecb(updateOld: bool) -> void:
	var highestPos = 0.0
	var leftmostPos = 0.0
	var rightmostPos = 0.0
	for i in range(ECB_Bones.size()):
		var boneName = ECB_Bones[i]
		var bonePosGlobal = FighterSkeleton.to_global(FighterSkeleton.get_bone_global_pose(FighterSkeleton.find_bone(boneName)).origin)
		bonePosGlobal -= position
		if bonePosGlobal.x <= leftmostPos:
			leftmostPos = bonePosGlobal.x
		if bonePosGlobal.x >= rightmostPos:
			rightmostPos = bonePosGlobal.x
		if bonePosGlobal.y > highestPos:
			highestPos = bonePosGlobal.y
	var ECBBot = Vector2(0,0)
	var ECBLeft = Vector2(leftmostPos, highestPos * 0.5)
	var ECBTop = Vector2(0, highestPos)
	var ECBRight = Vector2(rightmostPos, highestPos * 0.5)
	ECB[0][0] = ECBLeft
	ECB[0][1] = ECBTop
	ECB[0][2] = ECBRight
	ECB[1] = ftPos
	if updateOld:
		ECBOld = ECB.duplicate(true)

enum SurfaceSlope{
	WALL,
	FLOOR,
	CEIL
}

func get_surface_type(inNormal: Vector2) -> int:
	if inNormal.y > 0.1:
		return SurfaceSlope.FLOOR
	else: if inNormal.y > -0.85:
		return SurfaceSlope.WALL
	return SurfaceSlope.CEIL

func apply_traction() -> void:
	ftVel.x -= ftVel.x * FightTable.Friction
	ftVel.x = move_toward(ftVel.x, 0, FightTable.Friction * 0.05)

func apply_drag() -> void:
	ftVel.x -= ftVel.x * FightTable.AerialFriction
	ftVel.x = move_toward(ftVel.x, 0, FightTable.AerialFriction * 0.05)

func do_fighter_move_and_collide():
	ftPos += effectiveVel
	_calculate_ecb(false)
	depen_fighter_from_corners(0)
	try_fighter_ccd()
	depen_fighter_by_midpoint()
	draw_ecb()
	_calculate_ecb(true)

func depen_fighter_by_midpoint() -> void:
	for i in range(ECB[0].size()):
		for s in range(stage.StageCollisionSegments.size()):
			var segment = stage.StageCollisionSegments[s]
			if segment.colType == StageCollisionSegment.collisionType.semisolid:
				continue
			var segDir = (segment.endOffset - segment.startOffset).rotated(PI * 0.5).normalized()
			if (i == 0 or i == 2) and get_surface_type(segDir) == SurfaceSlope.FLOOR:
				continue
			if i == 1 and get_surface_type(segDir) != SurfaceSlope.CEIL:
				continue
			if i == 3 and get_surface_type(segDir) != SurfaceSlope.FLOOR:
				continue
			var mid = ftPos + ECB[0][1] * 0.5
			var dirFromMid = (ECB[0][i] - ECB[0][1] * 0.5).normalized()
			if dirFromMid.dot(segDir) > 0:
				continue
			var traceLength = (ECB[0][i] - ECB[0][1] * 0.5).length()
			#DebugDraw.draw_line(FHelp.Vec2to3(mid), FHelp.Vec2to3(mid + dirFromMid * traceLength), Color(1, 1, 1), 0.016666)
			var colResult = FHelp.TestRayLineIntersection(mid, dirFromMid, segment.startOffset, segment.endOffset)
			if colResult.hit and colResult.dist <= traceLength:
				var hitPoint = mid + dirFromMid * colResult.dist
				DebugDraw.draw_sphere(FHelp.Vec2to3(hitPoint), 0.2, Color(1, 0, 0), 0.01666)
				var move = -dirFromMid * ((traceLength - colResult.dist) + 0.1)
				ftPos += move
				_calculate_ecb(false)
				if i == 3 and effectiveVel.y < -1:
					grounded = true
					#ftVel.y = 0

func depen_fighter_from_corners(iter: int) -> void:
	if iter > 4: return
	var halfSpaces = [[ECB[0][0], ECB[0][1]], [ECB[0][1], ECB[0][2]], [ECB[0][2], ECB[0][3]], [ECB[0][3], ECB[0][0]]]
	halfSpaces = halfSpaces.duplicate(true)
	var depenned = false
	for i in range(halfSpaces.size()):
		halfSpaces[i].append((halfSpaces[i][1] - halfSpaces[i][0]).normalized().rotated(PI * -0.5))
		halfSpaces[i][0] += ftPos
		halfSpaces[i][1] += ftPos
	for s in range(stage.StageCollisionSegments.size()):
		if depenned:
			break
		var seg = stage.StageCollisionSegments[s]
		if seg.colType == StageCollisionSegment.collisionType.semisolid:
			continue
		var tests = [seg.startOffset, seg.endOffset]
		for test in range(tests.size()):
			var t = tests[test]
			if depenned:
				break
			var inside = true
			var closestDist = 1000
			var depenDir = Vector2.UP
			for hs in range(halfSpaces.size()):
				var i = halfSpaces[hs]
				if depenned:
					break
				#DebugDraw.draw_line(FHelp.Vec2to3(i[0]), FHelp.Vec2to3(i[1]), Color(0, 1, 1), 0.01666)
				#DebugDraw.draw_arrow_line(FHelp.Vec2to3((i[0] + i[1]) * 0.5), FHelp.Vec2to3((i[0] + i[1]) * 0.5 + i[2] * 2.5), Color(0, 1, 1), 0.4, 0.01666)
				var offset = t - i[0]
				var dist = offset.dot(i[2])
				if dist < 0:
					inside = false
				else:
					if dist < closestDist:
						closestDist = dist
						depenDir = i[2]
			if inside:
				var side = sign((t - ECB[1]).x)
				if side == 1:
					var test1 = halfSpaces[1]
					var test2 = halfSpaces[2]
					var intersect1 = FHelp.LineIntersection(t, t + Vector2.RIGHT, test1[0], test1[1]) - t
					var intersect2 = FHelp.LineIntersection(t, t + Vector2.RIGHT, test2[0], test2[1]) - t
					ftPos += Vector2.LEFT * min(intersect1.length(), intersect2.length())
					depenned = true
				else:
					var test1 = halfSpaces[0]
					var test2 = halfSpaces[3]
					var intersect1 = FHelp.LineIntersection(t, t + Vector2.LEFT, test1[0], test1[1]) - t
					var intersect2 = FHelp.LineIntersection(t, t + Vector2.LEFT, test2[0], test2[1]) - t
					ftPos += Vector2.RIGHT * min(intersect1.length() + 0.1, intersect2.length() + 0.1)
					depenned = true
				#DebugDraw.draw_sphere(FHelp.Vec2to3(t), 0.2, Color(1, 0, 0), 0.01666)
	if depenned:
		_calculate_ecb(false)
		depen_fighter_from_corners(iter + 1)

func try_fighter_ccd() -> void:
	for p in range(ECB[0].size()):
		# 0 = left
		# 1 = top
		# 2 = right
		# 3 = bot
		var oldP = ECBOld[0][p] + ECBOld[1]
		var desP = ECB[0][p] + ECB[1]
		var dir = (desP - oldP).normalized()
		var len = oldP.distance_to(desP)
		for s in range(stage.StageCollisionSegments.size()):
			var segment = stage.StageCollisionSegments[s]
			var segDir = (segment.endOffset - segment.startOffset).rotated(PI * 0.5).normalized()
			if dir.dot(segDir) > 0:
				continue
			if get_surface_type(segDir) == SurfaceSlope.WALL and (p != 0 and p != 2):
				continue
			if get_surface_type(segDir) == SurfaceSlope.FLOOR and (p == 1):
				continue
			if get_surface_type(segDir) == SurfaceSlope.CEIL and (p == 3):
				continue
			
			var colResult = FHelp.TestRayLineIntersection(oldP, dir, segment.startOffset, segment.endOffset)
			if colResult.hit and colResult.dist <= len:
				var hitPoint = oldP + dir * colResult.dist
				var depenDir = Vector2.LEFT
				match p:
					1:
						depenDir = Vector2.DOWN
					2:
						depenDir = Vector2.RIGHT
					3:
						depenDir = Vector2.UP
				var depenPoint = FHelp.LineIntersection(desP, desP + depenDir, segment.startOffset, segment.endOffset)
				# todo: just use a regular ray line intersection test, and if it misses,
				# assume we slid past, and move the player to either t2=0 or t2=1 by the point we're testing
				if is_nan(depenPoint.x) or is_nan(depenPoint.y) or is_inf(depenPoint.x) or is_inf(depenPoint.y):
					print("line intersect was NAN")
					continue
				ftPos += -depenDir * ((depenPoint - desP).length() + 0.1)
				if p == 3:
					grounded = true
				_calculate_ecb(false)

func construct_hurtboxes():
	if !Engine.is_editor_hint():
		return
	clear_hitboxes()
	var instanceCounter = 0
	for child in FighterSkeleton.get_children():
		if child is Hurtbox:
			child.queue_free()
	for hurtboxDef in Hurtboxes: 
		if !hurtboxDef:
			continue
		if FighterSkeleton.find_bone(hurtboxDef.boneName) == -1:
			continue
		var newHurtbox = preload("res://scenes/hurtbox.tscn")
		var newHurtboxInstance = newHurtbox.instantiate()
		newHurtboxInstance.boneName = hurtboxDef.boneName
		newHurtboxInstance.startOffset = hurtboxDef.startOffset
		newHurtboxInstance.endOffset = hurtboxDef.endOffset
		newHurtboxInstance.radius = hurtboxDef.radius
		instanceCounter += 3
		FighterSkeleton.add_child(newHurtboxInstance)
		newHurtboxInstance.position_debug_helpers()
	var anim = $AnimationPlayer as NetworkAnimationPlayer
	var oldAnimPos = anim.current_animation_position
	var frame = int(anim.current_animation_position * 60)
	unfold_action(find_state_by_anim(anim.assigned_animation).action)
	#print(curSubaction)
	for i in range(frame + 1):
		anim.seek(float(i) / 60.0, true)
		update_pose()
		if i < curSubaction.size():
			for subaction in curSubaction[i]:
				if subaction:
					subaction._execute(self)
		for hitboxDef in ActiveHitboxes:
			if !ActiveHitboxes:
				continue
			if FighterSkeleton.find_bone(hitboxDef.boneName) == -1:
				continue
			var boneID = FighterSkeleton.find_bone(hitboxDef.boneName)
			if boneID == -1:
				break
			var bonePose = FighterSkeleton.get_bone_global_pose(boneID)
			var globalPos = hitboxDef.offset
			globalPos = bonePose * globalPos
			globalPos = FighterSkeleton.to_global(globalPos)
			if hitboxDef.firstFrame:
				hitboxDef.firstFrame = false
				hitboxDef.curGlobalPosition = globalPos
				hitboxDef.oldGlobalPosition = globalPos
			else:
				hitboxDef.oldGlobalPosition = hitboxDef.curGlobalPosition
				hitboxDef.curGlobalPosition = globalPos
	anim.seek(oldAnimPos, true)
	update_pose()
	#print(ActiveHitboxes)
	for hitboxDef in ActiveHitboxes:
		if !ActiveHitboxes:
			continue
		if FighterSkeleton.find_bone(hitboxDef.boneName) == -1:
			continue
		var boneID = FighterSkeleton.find_bone(hitboxDef.boneName)
		if boneID == -1:
			break
		var newHitbox = preload("res://scenes/hurtbox.tscn")
		var newHitboxInstance = newHitbox.instantiate()
		newHitboxInstance.boneName = hitboxDef.boneName
		newHitboxInstance.startOffset = hitboxDef.oldGlobalPosition
		newHitboxInstance.endOffset = hitboxDef.curGlobalPosition
		newHitboxInstance.radius = hitboxDef.radius
		newHitboxInstance.isHitbox = true
		newHitboxInstance.angle = hitboxDef.kbAngle
		FighterSkeleton.add_child(newHitboxInstance)
		newHitboxInstance.position_debug_helpers()
		instanceCounter += 3
		for child in newHitboxInstance.get_children():
			var kfg = child as MeshInstance3D
			kfg.set_instance_shader_parameter("bubbleColor", Vector3(0.25, 0.0, 0.0))

func unfold_action(inAction: Array[Subaction]) -> void:
	curSubaction.clear()
	var subactionLength := 0
	var Unfolded : Array[Array] = []
	for i in range(inAction.size()):
		if inAction[i] is SetLoop:
			
			var maxLoopSize = 100
			var curLoopLength = 1
			var loopActive = true
			
			while loopActive:
				if inAction[i + curLoopLength] is SynchronousTimer:
					subactionLength += inAction[i + curLoopLength].frames * (inAction[i].LoopCount - 1)
				if inAction[i + curLoopLength] is ExecuteLoop:
					loopActive = false
					i = i + curLoopLength
				curLoopLength += 1
				if curLoopLength >= maxLoopSize:
					loopActive = false
					i += 1 # skip it
					print("Infinite loop?")
			
		if inAction[i] is SynchronousTimer:
			subactionLength += inAction[i].frames
			continue
			
		if inAction[i] is AsynchronousTimer:
			if subactionLength < inAction[i].frames:
				subactionLength = inAction[i].frames
			continue
			
	
	for i in range(subactionLength + 1):
		Unfolded.append([])
	
	var curIndex := 0
	var loopCount := 0
	var loopStart := 0
	var index = 0
	#print("Starting action parse")
	while index < inAction.size():
		#print(str(index) + ": " + inAction[index].SubactionName)
		if inAction[index] is SetLoop:
			loopStart = index + 1
			loopCount = inAction[index].LoopCount - 1
			index += 1
			continue
		if inAction[index] is ExecuteLoop:
			if loopCount > 0:
				index = loopStart
				loopCount -= 1
			else:
				index += 1
			#print("Loop activated. Going back to " + str(i))
			continue
		if inAction[index] is SynchronousTimer:
			curIndex += inAction[index].frames
			index += 1
			continue
		if inAction[index] is AsynchronousTimer:
			if curIndex < inAction[index].frames:
				curIndex = inAction[index].frames
			index += 1
			continue
		Unfolded[curIndex].append(inAction[index])
		index += 1
	#print("Action parsed!")
	#print(Unfolded.size())
	curSubaction = Unfolded

func blend_pose(anim1: String, anim2: String, frame1: int, frame2: int, blend: float) -> void:
	var pose1 = []
	var pose2 = []
	pose1.resize(FighterSkeleton.get_bone_count())
	pose2.resize(FighterSkeleton.get_bone_count())
	Animator.current_animation = anim1
	Animator.assigned_animation = anim1
	Animator.seek(float(frame1) / 60, true)
	update_pose()
	for i in range(FighterSkeleton.get_bone_count()):
		pose1[i] = FighterSkeleton.get_bone_pose(i)
	Animator.current_animation = anim2
	Animator.assigned_animation = anim2
	Animator.seek(float(frame2) / 60, true)
	update_pose()
	for i in range(FighterSkeleton.get_bone_count()):
		pose2[i] = FighterSkeleton.get_bone_pose(i)
	for i in range(FighterSkeleton.get_bone_count()):
		var blendTransform = pose1[i].interpolate_with(pose2[i], blend)
		FighterSkeleton.set_bone_pose_position(i, blendTransform.origin)
		FighterSkeleton.set_bone_pose_rotation(i, blendTransform.basis.get_rotation_quaternion())
		FighterSkeleton.set_bone_pose_scale(i, blendTransform.basis.get_scale())
	update_pose()

func _change_fighter_state(inState: FighterState, blend: int = 0, lag: int = 0) -> void:
	JustChangedState = true
	##if charState:
		##print("Leaving " + charState.stateName)
	oldPose.clear()
	oldPose.resize(FighterSkeleton.get_bone_count())
	for i in range(FighterSkeleton.get_bone_count()):
		oldPose[i] = FighterSkeleton.get_bone_pose(i)
	lastStateChange = internalFrameCounter
	charState = inState
	blendTime = blend
	InterruptableTime = lag
	for i in range(OnStateEnterFuncs.size()):
		OnStateEnterFuncs[i]._execute(self)
	for i in range(charState.onEnterState.size()):
		charState.onEnterState[i]._execute(self)
	
	TransNPhysics = charState.useAnimPhysics
	var TransN = FighterSkeleton.find_bone("TransN")
	var TransNNewTransform = FighterSkeleton.get_bone_global_pose(TransN)
	var TransNPos = FighterSkeleton.to_global(TransNNewTransform.origin)
	TransNPos -= position
	TransNOldPos = TransNPos
	
	if blendTime > 0:
		var ratio = float(get_frame_in_state() + 1) / blendTime
		for i in range(FighterSkeleton.get_bone_count()):
			var blendTransform = oldPose[i].interpolate_with(FighterSkeleton.get_bone_pose(i), ratio)
			FighterSkeleton.set_bone_pose_position(i, blendTransform.origin)
			FighterSkeleton.set_bone_pose_rotation(i, blendTransform.basis.get_rotation_quaternion())
			FighterSkeleton.set_bone_pose_scale(i, blendTransform.basis.get_scale())
	update_pose()
	execute_current_action(0)

func find_state_by_name(inState: String) -> FighterState:
	for fstate in States:
		if fstate.stateName == inState:
			return fstate
	return null

func find_state_by_anim(inAnim: String) -> FighterState:
	for fstate in States:
		if fstate.stateAnim == inAnim:
			return fstate
	return null

func _network_process(input: Dictionary) -> void:
	pass

func do_damage(inHurtbox: HurtboxDefinition, inHitbox: HitboxDefinition, victim: Fighter) -> void:
	FightersHit.append(victim)
	for i in range(victim.OnDamageFuncs.size()):
		victim.OnDamageFuncs[i]._execute(victim, inHurtbox, inHitbox, self)

func check_hitboxes() -> void:
	for i in range(ActiveHitboxes.size()):
		var curHitbox = ActiveHitboxes[i] as HitboxDefinition
		var boneID = FighterSkeleton.find_bone(curHitbox.boneName)
		if boneID == -1:
			break
		var bonePose = FighterSkeleton.get_bone_global_pose(boneID)
		var globalPos = curHitbox.offset
		globalPos = bonePose * globalPos
		globalPos = FighterSkeleton.to_global(globalPos)
		if curHitbox.firstFrame:
			curHitbox.firstFrame = false
			curHitbox.curGlobalPosition = globalPos
			curHitbox.oldGlobalPosition = globalPos
		else:
			curHitbox.oldGlobalPosition = curHitbox.curGlobalPosition
			curHitbox.curGlobalPosition = globalPos
		
		if curHitbox.oldGlobalPosition == curHitbox.curGlobalPosition:
			curHitbox.oldGlobalPosition += Vector3(0, 0.001, 0)
		
		#DebugDraw.draw_sphere(curHitbox.curGlobalPosition, curHitbox.radius, Color(1, 0, 0), 0.01666)
		for f in range(stage.fighters.size()):
			var curFighter = stage.fighters[f] as Fighter
			if curFighter == self:
				continue
			var alreadyHit = false
			for t in range(FightersHit.size()):
				if FightersHit[t] == curFighter:
					alreadyHit = true
			if alreadyHit:
				continue
			if curFighter.ourShield.active:
				var ss = curFighter.get_shield_size()
				var sp = curFighter.get_shield_position()
				var hitShield = FHelp.TestSphereCapsuleIntersection(sp, ss, curHitbox.curGlobalPosition, curHitbox.oldGlobalPosition, curHitbox.radius)
				if hitShield:
					FightersHit.append(curFighter)
					apply_shielded_hit_effects(curFighter, curHitbox)
					continue
			for h in range(curFighter.Hurtboxes.size()):
				var curHurtbox = curFighter.Hurtboxes[h] as HurtboxDefinition
				var hurtboxBonePose = curFighter.FighterSkeleton.get_bone_global_pose(FighterSkeleton.find_bone(curHurtbox.boneName))
				var globalStart = curHurtbox.startOffset
				var globalEnd = curHurtbox.endOffset
				globalStart = hurtboxBonePose * globalStart
				globalEnd = hurtboxBonePose * globalEnd
				globalStart = curFighter.FighterSkeleton.to_global(globalStart)
				globalEnd = curFighter.FighterSkeleton.to_global(globalEnd)
				var intersect = FHelp.TestCapsuleCapsuleIntersection(curHitbox.curGlobalPosition, curHitbox.oldGlobalPosition, curHitbox.radius, globalStart, globalEnd, curHurtbox.radius)
				if intersect:
					do_damage(curHurtbox, curHitbox, curFighter)
					break

func check_interrupts(recursion: int) -> void:
	if recursion > 3:
		print("Stopped an interrupt loop.")
		return
	var interruptedPrematurely = false
	if get_frame_in_state() >= InterruptableTime and hitStun == 0:
		for i in range(charState.interrupts.size()):
			if charState.interrupts[i].startActive:
				if charState.interrupts[i].disableTime != 0 and get_frame_in_state() >= charState.interrupts[i].disableTime:
					if charState.interrupts[i].enableTime == 0:
						continue
					else:
						if get_frame_in_state() < charState.interrupts[i].enableTime:
							continue
			else:
				if get_frame_in_state() < charState.interrupts[i].enableTime:
					continue
				if charState.interrupts[i].disableTime != 0 and get_frame_in_state() >= charState.interrupts[i].disableTime:
					continue
			if grounded:
				if charState.interrupts[i].requiredState == Interrupt.groundRequire.OnlyAirborne:
					continue
			else:
				if charState.interrupts[i].requiredState == Interrupt.groundRequire.OnlyGrounded:
					continue
			var interrupted = charState.interrupts[i]._execute(self)
			if interrupted: 
				#print("Interrupted into " + charState.stateName)
				interruptedPrematurely = true
				break
	if interruptedPrematurely:
		check_interrupts(recursion + 1)

func check_onframe() -> void:
	for i in range(OnFrameFuncs.size()):
		if JustChangedState:
			JustChangedState = false
			check_onframe()
			break
		OnFrameFuncs[i]._execute(self)
	for i in range(charState.onFrame.size()):
		if JustChangedState:
			JustChangedState = false
			check_onframe()
			break
		charState.onFrame[i]._execute(self)

func execute_current_action(actionFrame: int) -> void:
	if curSubaction.size() > actionFrame:
		DebugDraw.set_text("ACTION TIMER", str(actionFrame))
		for i in range(curSubaction[actionFrame].size()):
			var subaction = curSubaction[actionFrame][i]
			DebugDraw.set_text("SUBACTION", subaction.SubactionName)
			subaction._execute(self)

func update_pose() -> void:
	for i in range(FighterSkeleton.get_bone_count()):
		FighterSkeleton.force_update_bone_child_transform(i)

func apply_shielded_hit_effects(inVictim: Fighter, inHitbox: HitboxDefinition) -> void:
	var d = inHitbox.damage + inHitbox.damageShield
	var s = max(input_controller.get_trigger_analog_unbuffered(), 0.3)
	var a = 0.65 * (1 - ((s - 0.3) / 0.7))
	print(a)
	inVictim.shieldStun = 200 / 201 * (((d * (a + 0.3)) * 1.5) + 2)
	var side = sign((inVictim.ftPos - ftPos).x)
	inVictim.ftVel += Vector2((d * 0.09 + 0.4) * side, 0)
	ftVel += Vector2((d * 0.04 + 0.025) * -side, 0)
	var knockBack = FHelp.CalculateKnockback(inHitbox, self, inVictim)
	var c = 1
	var e = 1
	var ourHitlag = floor(c * floor(e * floor(3+inHitbox.damage/3)))
	hitLag = ourHitlag
	inVictim.hitLag = ourHitlag
	inVictim.ourShield.health = max(inVictim.ourShield.health - d, 0)
	print("shieldstun: " + str(inVictim.shieldStun))
	print("shield health:" + str(inVictim.ourShield.health))

func fighter_tick() -> void:
	
	var tests = []
	for ft in stage.fighters:
		tests.append(ft.input_controller.get_trigger_analog_unbuffered())
	
	DebugDraw.set_text("ACTION TIMER", "NO ACTION")
	DebugDraw.set_text("SUBACTION", "NO SUBACTION")
	if input_controller:
		if hitLag > 0 or shieldStun > 0:
			if hitLag > 0:
				hitLag -= 1
			if hitLag == 0:
				internalFrameCounter += 1
				var kbVelPerpendicular = kbVel.rotated(PI * 0.5)
				var moveRestrict = input_controller.get_movement_vector_unbuffered()
				if moveRestrict.length() > 1:
					moveRestrict = moveRestrict.normalized()
				var DirectionalInfluencePower = kbVelPerpendicular.dot(moveRestrict)
				var maxDIAng = deg_to_rad(18)
				kbVel = kbVel.rotated(maxDIAng * DirectionalInfluencePower)
			if shieldStun > 0:
				shieldStun -= 1
		else:
			internalFrameCounter += 1
			if hitStun > 0:
				hitStun -= 1
		
		if !ourShield.active:
			ourShield.health = min(ourShield.health + 0.1, ourShield.maxHealth)
		
		
		Animator.seek(float(get_frame_in_state() / 60.0), true)
		
		if get_frame_in_state() > Animator.current_animation_length * 60 and charState.onAnimFinishedState != "":
			_change_fighter_state(find_state_by_name(charState.onAnimFinishedState))
		
		#DebugDraw.set_text("Input Velocity: ", str(input_controller.get_movement_vector_velocity_unbuffered()))
		
		if get_frame_in_state() < blendTime:
			for i in range(FighterSkeleton.get_bone_count()):
				var ratio = float(get_frame_in_state() + 1) / blendTime
				var blendTransform = oldPose[i].interpolate_with(FighterSkeleton.get_bone_pose(i), ratio)
				FighterSkeleton.set_bone_pose_position(i, blendTransform.origin)
				FighterSkeleton.set_bone_pose_rotation(i, blendTransform.basis.get_rotation_quaternion())
				FighterSkeleton.set_bone_pose_scale(i, blendTransform.basis.get_scale())
		
		var TransNMotion = Transform3D.IDENTITY
		
		if TransNPhysics:
			var TransN = FighterSkeleton.find_bone("TransN")
			var TransNNewTransform = FighterSkeleton.get_bone_global_pose(TransN)
			var TransNPos = FighterSkeleton.to_global(TransNNewTransform.origin)
			TransNPos -= FHelp.Vec2to3(ftPos)
			TransNMotion = TransNPos - TransNOldPos
			TransNOldPos = TransNPos
			FighterSkeleton.set_bone_pose_position(TransN, Vector3.ZERO)
			FighterSkeleton.set_bone_pose_rotation(TransN, Quaternion.IDENTITY)
			FighterSkeleton.set_bone_pose_scale(TransN, Vector3.ONE)
			#print(TransNMotion)
			ftVel = FHelp.Vec3to2(TransNMotion)
		
		if hitLag == 0 and shieldStun == 0:
			check_interrupts(0)
			
			check_onframe()
			
			update_pose()
			
			effectiveVel = ftVel + kbVel
			
			do_fighter_move_and_collide()
			
			if get_frame_in_state() != 0:
				execute_current_action(get_frame_in_state())
			
			kbVel = kbVel.move_toward(Vector2.ZERO, 0.051)
			
			check_hitboxes()
		
		if kbVel.length() > 0:
			DebugDraw.set_text("KBVEL", kbVel)
	if ftPos.x < stage.StageBounds[0].x or ftPos.x > stage.StageBounds[1].x or ftPos.y < stage.StageBounds[0].y or ftPos.y > stage.StageBounds[1].y:
		respawn_self()
	position = FHelp.Vec2to3(ftPos)
	#var ss = get_shield_size()
	#var sp = get_shield_position()
	#DebugDraw.draw_sphere(sp, ss, Color(0.2, 0.5, 1), 0.01666)
	if hitStun > 0 and hitLag > 0:
		var RNG = RandomNumberGenerator.new()
		position.x += RNG.randf_range(-2, 2)
	DebugDraw.set_text("BUTTONS", input_controller.shield_down())
	DebugDraw.set_text("STATE", charState.stateName)
	DebugDraw.set_text("FLAGS: ", str(stateFlags))

func _save_state() -> Dictionary:
	return {
		_Hurtboxes = Hurtboxes.duplicate(),
		_FightersHit = FightersHit.duplicate(),
		_ActiveHitboxes = ActiveHitboxes.duplicate(),
		_curSubaction = curSubaction.duplicate(),
		_charState = charState.duplicate(),
		_shield = shield.duplicate(),
		_ourShield = ourShield.duplicate(),
		stateFlags = stateFlags,
		facing = facing,
		kbVel = kbVel,
		ftVel = ftVel,
		ftPos = ftPos,
		grounded = grounded,
		hitLag = hitLag,
		hitStun = hitStun,
		percentage = percentage,
		blendTime = blendTime,
		lastStateChange = lastStateChange,
		TransNPhysics = TransNPhysics,
		TransNOldPos = TransNOldPos,
		InterruptableTime = InterruptableTime,
		jumps = jumps,
		JustChangedState = JustChangedState,
		internalFrameCounter = internalFrameCounter,
		lastHitHurtbox = lastHitHurtbox,
		lastHitHitbox = lastHitHitbox,
		downDesire = downDesire,
		effectiveVel = effectiveVel,
		shieldStun = shieldStun,
		FightTable = FightTable.duplicate(),
		ECB_Bones = ECB_Bones.duplicate(),
		ECB = ECB.duplicate(),
		ECBOld = ECBOld.duplicate(),
		oldPose = oldPose.duplicate()
	}
	

func _load_state(state: Dictionary) -> void:
		Hurtboxes = state["_Hurtboxes"].duplicate()
		FightersHit = state["_FightersHit"].duplicate()
		ActiveHitboxes = state["_ActiveHitboxes"].duplicate()
		curSubaction = state["_curSubaction"].duplicate()
		charState = state["_charState"].duplicate()
		shield = state["_shield"].duplicate()
		ourShield = state["_ourShield"].duplicate()
		stateFlags = state["stateFlags"]
		facing = state["facing"]
		kbVel = state["kbVel"]
		ftVel = state["ftVel"]
		ftPos = state["ftPos"]
		grounded = state["grounded"]
		hitLag = state["hitLag"]
		hitStun = state["hitStun"]
		percentage = state["percentage"]
		blendTime = state["blendTime"]
		lastStateChange = state["lastStateChange"]
		TransNPhysics = state["TransNPhysics"]
		TransNOldPos = state["TransNOldPos"]
		InterruptableTime = state["InterruptableTime"]
		jumps = state["jumps"]
		JustChangedState = state["JustChangedState"]
		internalFrameCounter = state["internalFrameCounter"]
		lastHitHurtbox = state["lastHitHurtbox"]
		lastHitHitbox = state["lastHitHitbox"]
		downDesire = state["downDesire"]
		effectiveVel = state["effectiveVel"]
		shieldStun = state["shieldStun"]
		FightTable = state["FightTable"].duplicate()
		ECB_Bones = state["ECB_Bones"].duplicate()
		ECB = state["ECB"].duplicate()
		ECBOld = state["ECBOld"].duplicate()
		oldPose = state["oldPose"].duplicate()
