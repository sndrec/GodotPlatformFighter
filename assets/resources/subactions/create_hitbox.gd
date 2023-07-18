@tool

class_name CreateHitbox extends Subaction

var SubactionName = "Create Hitbox"

@export var boneName: String = "HipN"

@export var hitboxID: int = 0

@export var offset: Vector3 = Vector3.ZERO

@export var radius: float = 1.0

@export var damage: float = 0.0

@export var damageShield: float = 0.0

@export var kbAngle: float = 0.0

## If enabled, knockback angle won't be reversed when hitting enemies behind you.
## For moves that you always want to hit in a specific direction.
@export var kbAngleFixed: bool = false

## Fixed knockback, affected by weight.
@export var kbBase: float = 0.0

## Knockback increase with percent. Also affected by weight.
@export var kbGrowth: float = 0.0

## If this is anything except 0, damage, enemy weight and percentage, kbBase and kbGrowth
## will all be ignored when calculating knockback, relying on just this number alone.
@export var kbWeightSet: float = 0.0

@export var hitGrounded: bool = true

@export var hitAirborne: bool = true

func _execute (inFighter: Fighter) -> void:
	var newHitbox = HitboxDefinition.new()
	newHitbox.boneName = boneName
	newHitbox.hitboxID = hitboxID
	newHitbox.offset = offset
	newHitbox.radius = radius
	newHitbox.damage = damage
	newHitbox.damageShield = damageShield
	newHitbox.kbAngle = kbAngle
	newHitbox.kbAngleFixed = kbAngleFixed
	newHitbox.kbBase = kbBase
	newHitbox.kbGrowth = kbGrowth
	newHitbox.kbWeightSet = kbWeightSet
	newHitbox.HitGrounded = hitGrounded
	newHitbox.HitAirborne = hitAirborne
	newHitbox.firstFrame = true
	var alreadyExists = false
	for i in range(inFighter.ActiveHitboxes.size()):
		if inFighter.ActiveHitboxes[i].hitboxID == hitboxID:
			inFighter.ActiveHitboxes[i] = newHitbox
			alreadyExists = true
			break
	if !alreadyExists:
		inFighter.ActiveHitboxes.append(newHitbox)
		inFighter.ActiveHitboxes.sort_custom(func(a, b): return a.hitboxID < b.hitboxID)
