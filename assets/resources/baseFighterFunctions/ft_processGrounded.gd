class_name ProcessGrounded extends FighterFunction

func _execute(inFt: Fighter):
	if !inFt.grounded:
		inFt._change_fighter_state(inFt.find_state_by_name("Fall"), 0, 0)
		return
	inFt.ftVel.y = 0
	inFt.jumps = 0
	var tempInput = inFt.input_controller.get_movement_vector()
	var convInput = Vector3(tempInput.x, -tempInput.y, 0)
	if inFt.get_frame_in_state() < inFt.InterruptableTime:
		inFt.apply_traction()
	else: if absf(convInput.x) < 0.01:
		inFt.apply_traction()
	var hitAny = false
	for segment in inFt.stage.StageCollisionSegments:
		var segDir = (segment.endOffset - segment.startOffset).rotated(PI * 0.5).normalized()
		if inFt.get_surface_type(segDir) == inFt.SurfaceSlope.FLOOR:
			var testDist = 3
			var testStartPos = inFt.ftPos + Vector2.DOWN
			var traceResult = FHelp.TestRayLineIntersection(testStartPos, Vector2.UP, segment.startOffset, segment.endOffset)
			#DebugDraw.draw_line(FHelp.Vec2to3(testStartPos), FHelp.Vec2to3(testStartPos + Vector2.UP * testDist), Color(0, 0, 255), 0.01666)
			if traceResult.hit and traceResult.dist <= testDist:
				hitAny = true
				#print("we hit yay")
				var hitPos = testStartPos + Vector2.UP * traceResult.dist
				inFt.ftPos = hitPos + Vector2.DOWN * 0.1
	if !hitAny:
		#print("Dident hit anything.")
		inFt.grounded = false
		inFt._change_fighter_state(inFt.find_state_by_name("Fall"), 4, 0)
