@tool

class_name CreateTriggerbox extends Subaction

var SubactionName = "Create Triggerbox"

@export var boneName: String = "HipN"

@export var hitboxID: int = 0

@export var offset: Vector3 = Vector3.ZERO

@export var radius: float = 1.0

@export var triggerFuncs: Array[FighterFunction] = []

@export var hitGrounded: bool = true

@export var hitAirborne: bool = true

func _execute (inFighter: Fighter) -> void:
	var newHitbox = HitboxDefinition.new()
	newHitbox.boneName = boneName
	newHitbox.hitboxID = hitboxID
	newHitbox.offset = offset
	newHitbox.radius = radius
	newHitbox.HitGrounded = hitGrounded
	newHitbox.HitAirborne = hitAirborne
	newHitbox.TriggerFuncs = triggerFuncs
	newHitbox.IsTrigger = true
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
