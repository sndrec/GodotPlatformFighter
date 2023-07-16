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

@export var kbBase: float = 0.0

@export var kbGrowth: float = 0.0

@export var kbWeightSet: float = 0.0

func _execute (inFighter: Fighter) -> void:
	var newHitbox = HitboxDefinition.new()
	newHitbox.boneName = boneName
	newHitbox.hitboxID = hitboxID
	newHitbox.offset = offset
	newHitbox.radius = radius
	newHitbox.damage = damage
	newHitbox.damageShield = damageShield
	newHitbox.kbAngle = kbAngle
	newHitbox.kbBase = kbBase
	newHitbox.kbGrowth = kbGrowth
	newHitbox.kbWeightSet = kbWeightSet
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
