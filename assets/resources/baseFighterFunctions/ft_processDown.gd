class_name ProcessDown extends FighterFunction

func _execute(inFt: Fighter):
	if inFt.grounded:
		inFt.ftVel.y = 0
		inFt.jumps = 0
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
					if inFt.kbVel.y == 0:
						#print("we hit yay")
						var hitPos = testStartPos + Vector2.UP * traceResult.dist
						inFt.ftPos = hitPos + Vector2.DOWN * 0.1
		if !hitAny:
			#print("Dident hit anything.")
			inFt.grounded = false
			inFt._change_fighter_state(inFt.find_state_by_name("Fall"), 4, 0)
	else:
		if inFt.charState.stateName == "DownWait":
			inFt._change_fighter_state(inFt.find_state_by_name("Fall"), 4, 0)
		inFt.apply_drag()
		var terminalVelocity = -inFt.FightTable.TerminalVelocity
		inFt.ftVel.y = maxf(inFt.ftVel.y - inFt.FightTable.Gravity, -inFt.FightTable.TerminalVelocity)
