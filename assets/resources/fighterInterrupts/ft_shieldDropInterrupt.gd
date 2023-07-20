class_name ShieldDropInterrupt extends Interrupt

func _execute(inFt: Fighter) -> bool:
	if !inFt.input_controller.shield_down() and inFt.input_controller.get_trigger_analog_unbuffered() < 0.3:
		inFt._change_fighter_state(inFt.find_state_by_name("GuardOff"), 0, 0)
		inFt.ourShield.active = false
		inFt.get_node("ShieldSprite").visible = true
		return true
	return false
