class_name ExecuteGrab extends FighterFunction

func _execute(inHurtbox: HurtboxDefinition, inHitbox: HitboxDefinition, inVictim: Fighter, inAttacker: Fighter) -> void:
	inAttacker.GrabbedFighter = inVictim
	inVictim.ftVel = Vector2.ZERO
	inAttacker.clear_hitboxes()
	inVictim.clear_hitboxes()
	inVictim._change_fighter_state(inVictim.find_state_by_name("CapturePulled"), 2, 0)
	inAttacker._change_fighter_state(inAttacker.find_state_by_name("CatchWait"), 2, 0)
