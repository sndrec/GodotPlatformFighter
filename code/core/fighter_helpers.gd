@tool

extends Node

func Vec2to3(inVec: Vector2) -> Vector3:
	return Vector3(inVec.x, inVec.y, 0)

func Vec3to2(inVec: Vector3) -> Vector2:
	return Vector2(inVec.x, inVec.y)

func solveQuadraticEquation (a0: float, a1: float, a2: float, sign: float = 1) -> float:
	if (a1 == 0 && a2 == 0):
		if (a0 == 0):
			return -1 # convention
		else:
			return -32768
	else: if ( absf( a0*a0*a2/(a1*a1) ) < 1e-20 ):
		return (- a0 / a1)
	else:
		var disc = a1*a1 - 4*a0*a2
		if (disc < 0):
			return -32768 # non-real solutions
		else: if (sign(a1) == sign):
			# avoid catastrophic cancellation
			return 2 * a0 / (-a1 - sign * sqrt(disc)) 
		else:
			return ((-a1 + sign * sqrt(disc)) / (2 * a2) )

func lineSweepParameters(line1: Array[Vector2], line2: Array[Vector2], flip: bool = false) -> Array[float]:
	var sign = 1
	if (flip):
		sign = -1
	var x1 = line1[0].x
	var x2 = line1[1].x
	var x3 = line2[0].x
	var x4 = line2[1].x
	var y1 = line1[0].y
	var y2 = line1[1].y
	var y3 = line2[0].y
	var y4 = line2[1].y

	var a0 = x2 * y1 - x1 * y2
	var a1 = x4 * y1 - 2 * x2 * y1 + 2 * x1 * y2 - x3 * y2 + x2 * y3 - x1 * y4
	var a2 = x2 * y1 - x4 * y1 - x1 * y2 + x3 * y2 - x2 * y3 + x4 * y3 + x1 * y4 - x3 * y4

	# s satisfies the equation:	 a0 + a1*s + a2*s^2 = 0
	var s = solveQuadraticEquation(a0, a1, a2, sign)

	if (s == null || is_nan(s) || s == INF || s < 0 || s > 1):
		return [] # no real solution
	else:
		var t = ( s * (x1 - x3) - x1) / ( x2 - x1 + s * (x1 - x2 - x3 + x4) )

		if (is_nan(t) || t == INF || t < 0 || t > 1):
			return []
		else:
			return [t, s]

func closest_distance_between_lines(a0: Vector3, a1: Vector3, b0: Vector3, b1: Vector3):
	var result = {Line1Closest = Vector3.ZERO, Line2Closest = Vector3.ZERO, Distance = 0.0}
	var A := a1 - a0
	var B := b1 - b0
	var magA := A.length()
	var magB := B.length()
	var _A := A / magA
	var _B := B / magB
	var cross := _A.cross(_B)
	var denom := cross.length() * cross.length()
	if (denom == 0):
	
		var d0 := _A.dot(b0 - a0)
		
		var d1 := _A.dot(b1 - a0)
		
		if (d0 <= 0 && 0 >= d1):
		
			if (abs(d0) < abs(d1)):
			
				result.Line1Closest = a0
				result.Line2Closest = b0
				result.Distance = (a0 - b0).length()
				return result
			
			result.Line1Closest = a0
			result.Line2Closest = b1
			result.Distance = (a0 - b1).length()
			return result
		
		
		else: if (d0 >= magA && magA <= d1):
		
			if (abs(d0) < abs(d1)):
		
				result.Line1Closest = a1
				result.Line2Closest = b0
				result.Distance = (a1 - b0).length()
				return result
			
			result.Line1Closest = a1
			result.Line2Closest = b1
			result.Distance = (a1 - b1).length()
			return result
		
		
		result.Line1Closest = Vector3.ZERO
		result.Line2Closest = Vector3.ZERO
		result.Distance = (((d0 * _A) + a0) - b0).length()
		return result
	
	
	var t := (b0 - a0)
	var detA := Basis(t, _B, cross).determinant()
	var detB := Basis(t, _A, cross).determinant()
	var t0 := detA / denom
	var t1 := detB / denom
	var pA := a0 + (_A * t0) 
	var pB := b0 + (_B * t1) 
	
	if (t0 < 0):
		pA = a0
	else: if (t0 > magA):
		pA = a1
	if (t1 < 0):
		pB = b0
	else: if (t1 > magB):
		pB = b1
	var dot := 0.0
	
	
	if (t0 < 0 || t0 > magA):
	
		dot = _B.dot(pA - b0)
		if (dot < 0.0):
			dot = 0.0
		else: if (dot > magB):
			dot = magB
		pB = b0 + (_B * dot)
	
	
	if (t1 < 0 || t1 > magB):
	
		dot = _A.dot(pB - a0)
		if (dot < 0):
			dot = 0
		else: if (dot > magA):
			dot = magA
		pA = a0 + (_A * dot)
	
	result.Line1Closest = pA
	result.Line2Closest = pB
	result.Distance = (pA - pB).length()
	return result

func TestCapsuleCapsuleIntersection(a0: Vector3, a1: Vector3, ar: float, b0: Vector3, b1: Vector3, br: float) -> bool:
	var radiiSum := ar+br
	var lineSegmentTest = closest_distance_between_lines(a0, a1, b0, b1)
	if lineSegmentTest.Distance <= radiiSum:
		#DebugDraw.draw_sphere(a0, ar, Color(1, 0, 0), 1)
		#DebugDraw.draw_sphere(a1, ar, Color(1, 0, 0), 1)
		#DebugDraw.draw_sphere(b0, br, Color(1, 1, 0), 1)
		#DebugDraw.draw_sphere(b1, br, Color(1, 1, 0), 1)
		return true
	
	return false

func TestSphereCapsuleIntersection(a0: Vector3, ar: float, b0: Vector3, b1: Vector3, br: float) -> bool:
	var radiiSum := ar+br
	var lineSegmentTest = closest_distance_between_lines(a0, a0 + Vector3(0, 0, 0.001), b0, b1)
	if lineSegmentTest.Distance <= radiiSum:
		return true
	
	return false

func TestSphereSphereIntersection(a: Vector3, ar: float, b: Vector3, br: float) -> bool:
	var radiiSum := ar+br
	b -= a
	if b.length_squared() <= radiiSum * radiiSum:
		return true
	
	return false

func TestRayLineIntersection(a0: Vector2, aDir: Vector2, b0: Vector2, b1: Vector2) -> Dictionary:
	var result = {
		hit = false,
		dist = 0,
		side = -1
	}
	var v1 := a0 - b0
	var v2 := b1 - b0
	var v3 := Vector2(-aDir.y, aDir.x)
	
	var dot := v2.dot(v3)
	if (abs(dot) < 0.000001):
		return result
	
	var t1 := v2.cross(v1) / dot
	var t2 := v1.dot(v3) / dot
	
	if (t1 >= 0.0 && (t2 >= 0.0 && t2 <= 1.0)):
		result.hit = true
		result.dist = t1
		return result
	
	return result

func LineIntersection (s1: Vector2, e1: Vector2, s2: Vector2, e2: Vector2) -> Vector2:
	var d = (s1.x - e1.x) * (s2.y - e2.y) - (s1.y - e1.y) * (s2.x - e2.x)
	var a = s1.x * e1.y - s1.y * e1.x
	var b = s2.x * e2.y - s2.y * e2.x
	var x = (a * (s2.x - e2.x) - (s1.x - e1.x) * b) / d
	var y = (a * (s2.y - e2.y) - (s1.y - e1.y) * b) / d
	return Vector2(x, y)

func CalculateKnockback(inHitbox: HitboxDefinition, attacker: Fighter, victim: Fighter) -> float:
	var p = victim.percentage
	var d = inHitbox.damage
	var w = victim.FightTable.Weight
	if inHitbox.kbWeightSet > 0.0:
		p = 10
		d = inHitbox.kbWeightSet
		w = 100
	var knockback = ((p * 0.1) + ((p * d) * 0.05))
	knockback *= (200 / (w + 100)) * 1.4
	knockback += 18
	if inHitbox.kbWeightSet == 0.0:
		knockback *= inHitbox.kbGrowth * 0.01
		knockback += inHitbox.kbBase
	return knockback
