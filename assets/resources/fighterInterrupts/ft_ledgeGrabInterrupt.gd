class_name LedgeGrabInterrupt extends Interrupt

enum GrabFacing {
	FORWARD,
	BACKWARD,
	BOTH
}

enum GrabDir {
	RISING,
	FALLING,
	BOTH
}

@export var GrabDirection: GrabFacing = GrabFacing.FORWARD

@export var CanGrabWhen: GrabDir = GrabDir.FALLING

func _execute(inFt: Fighter) -> bool:
	if inFt.internalFrameCounter < inFt.lastTimeOnLedge + 30:
		return false
	var globalGrabBox = Rect2(inFt.ledgeBox.position + inFt.ftPos, inFt.ledgeBox.size)
	DebugDraw.draw_box(FHelp.Vec2to3(globalGrabBox.position), FHelp.Vec2to3(globalGrabBox.size), Color(1, 0, 0), false, 0.01666)
	var canGrab = false
	var pointToGrab: StageLedgePoint
	var effVel = inFt.ftVel + inFt.kbVel + inFt.animVel
	for i in range(inFt.stage.StageLedgePoints.size()):
		var p = inFt.stage.StageLedgePoints[i]
		var pInsideBox = globalGrabBox.has_point(p.pos)
		if !pInsideBox:
			continue
		pointToGrab = p
		var pointDir = sign((p.pos - inFt.ftPos).x)
		if pointDir == p.dir:
			continue
		if CanGrabWhen == GrabDir.BOTH and GrabDirection == GrabFacing.BOTH:
			canGrab = true
			break
		if CanGrabWhen == GrabDir.BOTH:
			if GrabDirection == GrabFacing.FORWARD:
				canGrab = pointDir == inFt.facing
			else:
				canGrab = pointDir != inFt.facing
		else: if CanGrabWhen == GrabDir.RISING:
			if GrabDirection == GrabFacing.FORWARD:
				canGrab = pointDir == inFt.facing
			else: if GrabDirection == GrabFacing.BACKWARD:
				canGrab = pointDir != inFt.facing
			else:
				canGrab = true
			canGrab = canGrab and effVel.y > 0
		else:
			if GrabDirection == GrabFacing.FORWARD:
				canGrab = pointDir == inFt.facing
			else: if GrabDirection == GrabFacing.BACKWARD:
				canGrab = pointDir != inFt.facing
			else:
				canGrab = true
			canGrab = canGrab and effVel.y < 0
		if canGrab:
			break
	if canGrab:
		inFt.currentLedge = pointToGrab
		inFt.facing = -pointToGrab.dir
		inFt.ftVel = Vector2.ZERO
		inFt.kbVel = Vector2.ZERO
		inFt.jumps = 1
		inFt._change_fighter_state(inFt.find_state_by_name("CliffCatch"), 0, 0)
		return true
	return false
