@tool

class_name ExecuteThrow extends Subaction

var SubactionName = "Execute Throw"

@export var ThrowAngle : float = 0.0

@export var ThrowDamage : float = 0.0

@export var ThrowBaseKB : float = 0.0

@export var ThrowKBGrowth : float = 0.0

@export var ThrowWeightBasedSetKB : float = 0.0

func _execute(inFt: Fighter) -> void:
	var grabbedRef = inFt.stage.fighters[inFt.GrabbedFighter]
	inFt.GrabbedFighter = -1
	var tempHitbox = preload("res://assets/resources/hitbox_definition.tres").duplicate()
	tempHitbox.damage = ThrowDamage
	tempHitbox.kbAngleFixed = true
	tempHitbox.kbAngle = ThrowAngle
	tempHitbox.kbBase = ThrowBaseKB
	tempHitbox.kbGrowth = ThrowKBGrowth
	tempHitbox.kbWeightSet = ThrowWeightBasedSetKB
	inFt.do_damage(grabbedRef.Hurtboxes[0], tempHitbox, grabbedRef)
