class_name OnDamage extends FighterFunction

var DownStates: Dictionary = {
	"DownBound" = true,
	"DownWait" = true,
	"DownDamage" = true
}

func _execute(inFt: Fighter, inHurtbox: HurtboxDefinition, inHitbox: HitboxDefinition, attacker: Fighter) -> void:
	inFt.percentage += inHitbox.damage
	var knockBack = FHelp.CalculateKnockback(inHitbox, attacker, inFt)
	# tumble threshold is 80 knockback!
	# 
	var side = sign(inFt.ftPos.x - attacker.ftPos.x)
	var kbAngle = Vector2.from_angle(inHitbox.kbAngle)
	kbAngle.x *= attacker.facing
	var kbVelMult = 1.0
	if !inHitbox.kbAngleFixed and side != attacker.facing:
		kbAngle.x *= -1
	var oldFacing = inFt.facing
	inFt.facing = -side
	inFt.ftVel = Vector2.ZERO
	inFt.kbVel = kbAngle * knockBack * 0.03 * kbVelMult
	inFt.hitStun = floor(knockBack * 0.4)
	var c = 1
	var e = 1
	var ourHitlag = floor(c * floor(e * floor(3+inHitbox.damage/3)))
	inFt.hitLag = ourHitlag
	attacker.hitLag = ourHitlag
	print("Knockback: " + str(knockBack))
	print("Hitstun: " + str(inFt.hitStun))
	print("Hitlag: " + str(ourHitlag))
	var desiredAnim = "DamageN1"
	if knockBack < 80:
		if DownStates.has(inFt.charState.stateName) and knockBack <= 25:
			inFt._change_fighter_state(inFt.find_state_by_name("DownDamage"), 0, 0)
			desiredAnim = "DownDamage" + inFt.downDesire
			inFt.facing = oldFacing
		else:
			inFt._change_fighter_state(inFt.find_state_by_name("Damage"), 0, 0)
			if inFt.grounded:
				if knockBack < 27:
					if inHurtbox.bodyType == HurtboxDefinition.hurtboxBodyType.High:
						desiredAnim = "DamageHi1"
					else: if inHurtbox.bodyType == HurtboxDefinition.hurtboxBodyType.Middle:
						desiredAnim = "DamageN1"
					else:
						desiredAnim = "DamageLw1"
				else: if knockBack < 54:
					if inHurtbox.bodyType == HurtboxDefinition.hurtboxBodyType.High:
						desiredAnim = "DamageHi2"
					else: if inHurtbox.bodyType == HurtboxDefinition.hurtboxBodyType.Middle:
						desiredAnim = "DamageN2"
					else:
						desiredAnim = "DamageLw2"
				else:
					if inHurtbox.bodyType == HurtboxDefinition.hurtboxBodyType.High:
						desiredAnim = "DamageHi3"
					else: if inHurtbox.bodyType == HurtboxDefinition.hurtboxBodyType.Middle:
						desiredAnim = "DamageN3"
					else:
						desiredAnim = "DamageLw3"
			else:
				if knockBack < 27:
					desiredAnim = "DamageAir1"
				else: if knockBack < 54:
					desiredAnim = "DamageAir2"
				else:
					desiredAnim = "DamageAir3"
	else:
		inFt._change_fighter_state(inFt.find_state_by_name("DamageFly"), 0, 0)
		if inFt.grounded and inFt.kbVel.y < 0:
			print("Started grounded, and spiked - let's invert the y.")
			inFt.kbVel.y *= -0.8
		if inHurtbox.bodyType == HurtboxDefinition.hurtboxBodyType.High:
			desiredAnim = "DamageFlyHi"
		else: if inHurtbox.bodyType == HurtboxDefinition.hurtboxBodyType.Middle:
			desiredAnim = "DamageFlyN"
		else:
			desiredAnim = "DamageFlyLw"
		if inHitbox.kbAngle > PI * 0.333 and inHitbox.kbAngle < PI * 0.666:
			desiredAnim = "DamageFlyTop"
	inFt.Animator.current_animation = desiredAnim
	inFt.Animator.assigned_animation = desiredAnim
	inFt.Animator.seek(1 / 60, true)
	inFt.update_pose()
	inFt.grounded = false
	inFt.badgeGrid.update_player_percent(inFt)
