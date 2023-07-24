class_name ProcessShielding extends OnFrame

## Whether this just affects the visual shield,
## or actually enables the shield and applies the shield pose.
@export var OnlyVisual: bool = true

func _execute(inFt: Fighter) -> void:
	if !OnlyVisual:
		var inp = inFt.input_controller.get_movement_vector_unbuffered()
		inp.x *= -inFt.facing
		var shieldAngle = inp.angle()
		var shieldAngleStrength = min(inp.length(), 1)
		var shieldAngleConverted = (int(floor(rad_to_deg(shieldAngle))) % 360) + 190
		inFt.blend_pose("Guard", "Guard", 0, shieldAngleConverted, shieldAngleStrength)
	inFt.ourShield.active = true
	var shieldPos := inFt.get_shield_position()
	var shieldSprite = inFt.get_node("ShieldSprite") as Sprite3D
	shieldSprite.global_position = shieldPos
	var triggerWithDeadzone = move_toward(inFt.input_controller.get_trigger_analog_unbuffered(), 0, 0.1) * 1.1111
	var shieldFinalSize = inFt.get_shield_size()
	shieldSprite.scale = Vector3(shieldFinalSize, shieldFinalSize, shieldFinalSize)
	shieldSprite.visible = true
	shieldSprite.modulate.a = triggerWithDeadzone * 0.4
