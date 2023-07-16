@tool

extends Node3D

class_name Fighter

var lastConstruct = 0.0
@onready var Animator: NetworkAnimationPlayer = $AnimationPlayer
@onready var FighterSkeleton: Skeleton3D = $Skeleton3D
var input_controller: BasePlayer
var stage: PFStage
@export var UpdateHurtboxes = false:
	set(inHurt):
		construct_hurtboxes()
		UpdateHurtboxes = inHurt


@export var Hurtboxes: Array[HurtboxDefinition] = []
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
@export var ECB_Bones: Array[String] = []
@export var OnStateEnterFunc: FighterFunction
@export var OnFrameFunc: FighterFunction
@export var States: Array[FighterState] = []

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

enum action_state {
	WAIT,
	WALK_SLOW,
	WALK_MIDDLE,
	WALK_FAST,
	DASH,
	RUN,
	RUN_BRAKE,
	RUN_TURN,
	TURN,
	JUMPSQUAT,
	JUMP_F,
	JUMP_B,
	JUMP_AERIAL_F,
	JUMP_AERIAL_B,
	FALL,
	SPECIAL_FALL,
	LANDING,
	TEETER,
	PLATFORM_DROP,
	LEDGE_CATCH,
	LEDGE_WAIT,
	LEDGE_GETUP_QUICK,
	LEDGE_GETUP_SLOW,
	LEDGE_ROLL_QUICK,
	LEDGE_ROLL_SLOW,
	LEDGE_JUMP_QUICK,
	LEDGE_JUMP_SLOW,
	LEDGE_ATTACK_QUICK,
	LEDGE_ATTACK_SLOW,
	ATTACK_JAB_1,
	ATTACK_JAB_2,
	ATTACK_JAB_3,
	ATTACK_JAB_REPEATING,
	ATTACK_JAB_REPEATING_END,
	ATTACK_DASH,
	ATTACK_TILT_HI,
	ATTACK_TILT_MID_HI,
	ATTACK_TILT_MID,
	ATTACK_TILT_MID_LOW,
	ATTACK_TILT_LOW,
	ATTACK_STRONG_HI,
	ATTACK_STRONG_MID_HI,
	ATTACK_STRONG_MID,
	ATTACK_STRONG_MID_LOW,
	ATTACK_STRONG_LOW,
	ATTACK_AERIAL_F,
	ATTACK_AERIAL_B,
	ATTACK_AERIAL_HI,
	ATTACK_AERIAL_LOW,
	ATTACK_AERIAL_N,
	GRAB,
	GRAB_DASH,
	GRAB_WAIT,
	GRAB_PUMMEL,
	GRAB_CUT,
	THROW_F,
	THROW_HI,
	THROW_B,
	THROW_LOW,
	GRABBED_HI_START,
	GRABBED_HI_WAIT,
	GRABBED_HI_DAMAGE,
	GRABBED_LOW_START,
	GRABBED_LOW_WAIT,
	GRABBED_LOW_DAMAGE,
	GRABBED_CUT,
	GRABBED_JUMP,
	LANDING_AIR_F,
	LANDING_AIR_B,
	LANDING_AIR_HI,
	LANDING_AIR_LOW,
	LANDING_AIR_N,
	ESCAPE_SPOT,
	ESCAPE_F,
	ESCAPE_B,
	ESCAPE_AIR,
	SHIELD_ACTIVATE,
	SHIELD_HOLD,
	SHIELD_DEACTIVATE,
	SHIELD_DAMAGE,
	CROUCH,
	CROUCH_WAIT,
	CROUCH_UNCROUCH,
	DAMAGEFALL,
	DAMAGE,
	DAMAGE_AIR,
	DAMAGE_FLY,
	DAMAGE_WALL,
	DOWN_BOUND,
	DOWN_WAIT,
	DOWN_DAMAGE,
	DOWN_STAND,
	DOWN_ATTACK,
	DOWN_FORWARD,
	DOWN_BACK,
	TECH_INPLACE,
	TECH_FORWARD,
	TECH_BACKWARD,
	TECH_WALL,
	TECH_WALLJUMP,
	TECH_CEIL,
	SHIELD_BROKEN,
	MISS_FOOT
}

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

func _network_spawn(data: Dictionary) -> void:
	position = data["position"]
	input_controller = data["controller"]
	_change_fighter_state(States[0])

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

func draw_ecb() -> void:
	var ECBBot = Vector3(0,0,0)
	var ECBLeft = Vector3(ECB[0].x, ECB[1].y * 0.5,0)
	var ECBTop = Vector3(0, ECB[1].y,0)
	var ECBRight = Vector3(ECB[2].x, ECB[1].y * 0.5,0)
	DebugDraw.draw_line(position, position + ECBLeft, Color(1, 1, 0, 1), 0.016666)
	DebugDraw.draw_line(position + ECBLeft, position + ECBTop, Color(1, 1, 0, 1), 0.016666)
	DebugDraw.draw_line(position + ECBTop, position + ECBRight, Color(1, 1, 0, 1), 0.016666)
	DebugDraw.draw_line(position + ECBRight, position + ECBBot, Color(1, 1, 0, 1), 0.016666)

func _calculate_ecb() -> void:
	ECBOld = ECB.duplicate(true)
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

enum SurfaceSlope{
	WALL,
	FLOOR,
	CEIL
}

func get_surface_type(inNormal: Vector2) -> int:
	if inNormal.y > 0.1:
		return SurfaceSlope.FLOOR
	else: if inNormal.y > -0.9:
		return SurfaceSlope.WALL
	return SurfaceSlope.CEIL

func apply_traction() -> void:
	ftVel.x -= ftVel.x * FightTable.Friction
	ftVel.x = move_toward(ftVel.x, 0, FightTable.Friction * 0.05)

func apply_drag() -> void:
	ftVel.x -= ftVel.x * FightTable.AerialFriction
	ftVel.x = move_toward(ftVel.x, 0, FightTable.AerialFriction * 0.05)

func do_fighter_move_and_collide() -> void:
	var collided = false
	var count = 0
	ftPos += ftVel + kbVel
	_calculate_ecb()
	for i in range(ECB[0].size()):
		#adjPoint is each ECB point in global space
		#print(ECB[count])
		var adjPointOld = ECBOld[0][count] + ECBOld[1]
		var adjPoint = ECB[0][count] + ftPos
		var pointDir = adjPoint - adjPointOld
		var traceLength = pointDir.length()
		pointDir = pointDir.normalized()
		#DebugDraw.draw_line(FHelp.Vec2to3(ECBMiddle), FHelp.Vec2to3(ECBMiddle + adjPoint), Color(1, 0, 0), 0.01666)
		for s in range(stage.StageCollisionSegments.size()):
			var segment = stage.StageCollisionSegments[s]
			if segment.colType == StageCollisionSegment.collisionType.semisolid and count == 3 and ftVel.y > 0:
				continue
			
			var segDir = (segment.endOffset - segment.startOffset).rotated(PI * 0.5).normalized()
			
			if (count == 0 or count == 2) and get_surface_type(segDir) != SurfaceSlope.WALL:
				#print("exit on 0 or 2")
				continue
			if count == 1 and get_surface_type(segDir) != SurfaceSlope.CEIL:
				#print("exit on 1")
				continue
			if count == 3 and get_surface_type(segDir) != SurfaceSlope.FLOOR:
				#print("exit on 3")
				continue
			#print("let's test on " + str(count))
			var colResult = FHelp.TestRayLineIntersection(adjPointOld, pointDir, segment.startOffset, segment.endOffset)
			#DebugDraw.draw_line(FHelp.Vec2to3(adjPointOld), FHelp.Vec2to3(adjPoint), Color(255, 255, 0), 0.016666)
			if colResult.hit and colResult.dist <= traceLength:
				if count == 3 and ftVel.y > 0:
						continue
				if count != 3 and segment.colType == StageCollisionSegment.collisionType.semisolid:
					continue
				#hitpoint is in global space
				var hitPoint = adjPointOld + pointDir * colResult.dist
				#DebugDraw.draw_sphere(FHelp.Vec2to3(hitPoint), 0.5, Color(1, 0, 0), 0.25)
				#print(adjPoint.length())
				#print(colResult.dist)
				var offsetToContact = ECB[0][count]
				
				ftPos = hitPoint + -offsetToContact + segDir * 0.1
				if count == 3:
					grounded = true
					#ftVel.y = 0
		count += 1
	_calculate_ecb()

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
	var anim = $AnimationPlayer as NetworkAnimationPlayer
	var frame = int(anim.current_animation_position * 60)
	unfold_action(find_state_by_anim(anim.assigned_animation).action)
	#print(curSubaction)
	for i in range(frame + 1):
		if i < curSubaction.size():
			for subaction in curSubaction[i]:
				subaction._execute(self)
	
	#print(ActiveHitboxes)
	for hitboxDef in ActiveHitboxes:
		if !ActiveHitboxes:
			continue
		if FighterSkeleton.find_bone(hitboxDef.boneName) == -1:
			continue
		var newHitbox = preload("res://scenes/hurtbox.tscn")
		var newHitboxInstance = newHitbox.instantiate()
		newHitboxInstance.boneName = hitboxDef.boneName
		newHitboxInstance.startOffset = hitboxDef.offset
		newHitboxInstance.endOffset = hitboxDef.offset
		newHitboxInstance.radius = hitboxDef.radius
		newHitboxInstance.isHitbox = true
		newHitboxInstance.angle = hitboxDef.kbAngle
		FighterSkeleton.add_child(newHitboxInstance)
		instanceCounter += 3
		for child in newHitboxInstance.get_children():
			var kfg = child as MeshInstance3D
			kfg.set_instance_shader_parameter("bubbleColor", Vector3(0.1, 0.0, 0.0))

func unfold_action(inAction: Array[Subaction]) -> void:
	curSubaction.clear()
	var subactionLength := 0
	var Unfolded : Array[Array] = []
	for i in range(inAction.size()):
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
	
	for i in range(inAction.size()):
		if inAction[i] is SynchronousTimer:
			curIndex += inAction[i].frames
			continue
		if inAction[i] is AsynchronousTimer:
			if curIndex < inAction[i].frames:
				curIndex = inAction[i].frames
			continue
		Unfolded[curIndex].append(inAction[i])
	curSubaction = Unfolded

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
	if OnStateEnterFunc:
		OnStateEnterFunc._execute(self)
	for i in range(charState.onEnterState.size()):
		charState.onEnterState[i]._execute(self)
	execute_current_action(0)
	#print("entering state " + inState.stateName)

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

func do_damage(inHitbox: HitboxDefinition, victim: Fighter) -> void:
	FightersHit.append(victim)
	victim.take_damage(inHitbox, self)

func take_damage(inHitbox: HitboxDefinition, attacker: Fighter) -> void:
	percentage += inHitbox.damage
	var knockBack = FHelp.CalculateKnockback(inHitbox, attacker, self)
	var side = sign(ftPos.x - attacker.ftPos.x)
	var kbAngle = Vector2.from_angle(inHitbox.kbAngle)
	kbAngle.x *= side
	ftVel = Vector2.ZERO
	kbVel = kbAngle * knockBack * 0.03
	hitStun = floor(knockBack * 0.4)
	var c = 1
	var e = 1
	var ourHitlag = floor(c * floor(e * floor(3+inHitbox.damage/3)))
	hitLag = ourHitlag
	attacker.hitLag = ourHitlag

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
		
		for f in range(stage.fighters.size()):
			var curFighter = stage.fighters[f] as Fighter
			if curFighter == self:
				continue
			var alreadyHit = false
			for t in range(FightersHit.size()):
				if FightersHit[t] == curFighter:
					alreadyHit = true
			if alreadyHit:
				break
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
					do_damage(curHitbox, curFighter)
					break

func check_interrupts(recursion: int) -> void:
	if recursion > 3:
		print("Stopped an interrupt loop.")
		return
	var interruptedPrematurely = false
	if get_frame_in_state() >= InterruptableTime:
		for i in range(charState.interrupts.size()):
			var interrupted = charState.interrupts[i]._execute(self)
			if interrupted: 
				interruptedPrematurely = true
				break
	if interruptedPrematurely:
		check_interrupts(recursion + 1)

func check_onframe() -> void:
	for i in range(charState.onFrame.size()):
		if JustChangedState:
			JustChangedState = false
			check_onframe()
			break
		if OnFrameFunc:
			OnFrameFunc._execute(self)
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

func fighter_tick() -> void:
	
	
	if input_controller:
		
		if hitLag > 0:
			hitLag -= 1
		else:
			internalFrameCounter += 1
		
		Animator.seek(float(get_frame_in_state() / 60.0), true)
		
		if get_frame_in_state() > Animator.current_animation_length * 60 and charState.onAnimFinishedState != "":
			_change_fighter_state(find_state_by_name(charState.onAnimFinishedState))
		
		#DebugDraw.set_text("Input Velocity: ", str(input_controller.get_movement_vector_velocity()))
		
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
		
		if hitLag == 0:
			check_interrupts(0)
			
			check_onframe()
			
			update_pose()
			
			do_fighter_move_and_collide()
			
			if get_frame_in_state() != 0:
				execute_current_action(get_frame_in_state())
			
			kbVel = kbVel.move_toward(Vector2.ZERO, 0.051)
			
			check_hitboxes()
		
	#draw_ecb()
	ftPos.x = clampf(ftPos.x, -90, 90)
	ftPos.y = clampf(ftPos.y, -50, 50)
	position = FHelp.Vec2to3(ftPos)
	DebugDraw.set_text("BUTTONS", input_controller.shield_down())
	DebugDraw.set_text("STATE", charState.stateName)
	DebugDraw.set_text("ACTION TIMER", "NO ACTION")
	DebugDraw.set_text("SUBACTION", "NO SUBACTION")
	DebugDraw.set_text("FLAGS: ", str(stateFlags))

func _save_state() -> Dictionary:
	return {
		position = position,
		Hurtboxes = Hurtboxes.duplicate(),
		FightTable = FightTable.duplicate(),
		ECB_Bones = ECB_Bones.duplicate(),
		States = States.duplicate(),
		ECB = ECB.duplicate(),
		ECBOld = ECBOld.duplicate(),
		ActiveHitboxes = ActiveHitboxes.duplicate(),
		curSubaction = curSubaction.duplicate(),
		stateFlags = stateFlags,
		FightersHit = FightersHit.duplicate(),
		facing = facing,
		kbVel = kbVel,
		ftVel = ftVel,
		ftPos = ftPos,
		grounded = grounded,
		hitLag = hitLag,
		hitStun = hitStun,
		percentage = percentage,
		charState = charState.duplicate(),
		oldPose = oldPose.duplicate(),
		blendTime = blendTime,
		lastStateChange = lastStateChange,
		TransNPhysics = TransNPhysics,
		TransNOldPos = TransNOldPos,
		InterruptableTime = InterruptableTime,
		jumps = jumps,
		JustChangedState = JustChangedState,
		internalFrameCounter = internalFrameCounter
	}
	

func _load_state(state: Dictionary) -> void:
		position = state["position"]
		Hurtboxes = state["Hurtboxes"].duplicate()
		FightTable = state["FightTable"].duplicate()
		ECB_Bones = state["ECB_Bones"].duplicate()
		States = state["States"].duplicate()
		ECB = state["ECB"].duplicate()
		ECBOld = state["ECBOld"].duplicate()
		ActiveHitboxes = state["ActiveHitboxes"].duplicate()
		curSubaction = state["curSubaction"].duplicate()
		stateFlags = state["stateFlags"]
		FightersHit = state["FightersHit"].duplicate()
		facing = state["facing"]
		kbVel = state["kbVel"]
		ftVel = state["ftVel"]
		ftPos = state["ftPos"]
		grounded = state["grounded"]
		hitLag = state["hitLag"]
		hitStun = state["hitStun"]
		percentage = state["percentage"]
		charState = state["charState"].duplicate()
		oldPose = state["oldPose"].duplicate()
		blendTime = state["blendTime"]
		lastStateChange = state["lastStateChange"]
		TransNPhysics = state["TransNPhysics"]
		TransNOldPos = state["TransNOldPos"]
		InterruptableTime = state["InterruptableTime"]
		jumps = state["jumps"]
		JustChangedState = state["JustChangedState"]
		internalFrameCounter = state["internalFrameCounter"]
