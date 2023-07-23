extends Resource

class_name HitboxDefinition

var boneName: String = "HipN"

var hitboxID: int = 0

var offset: Vector3 = Vector3.ZERO

var radius: float = 1.0

var damage: float = 0.0

var damageShield: float = 0.0

var kbAngle: float = 0.0

var kbAngleFixed: bool = false

var kbBase: float = 0.0

var kbGrowth: float = 0.0

var kbWeightSet: float = 0.0

var HitAirborne: bool = true

var HitGrounded: bool = true

var IsTrigger: bool = false

var TriggerFuncs: Array[FighterFunction] = []

var firstFrame = true

var curGlobalPosition: Vector3 = Vector3.ZERO

var oldGlobalPosition: Vector3 = Vector3.ZERO

func _init(p_boneName := "HipN", p_hitboxID := 0, p_offset := Vector3.ZERO, p_radius := 1.0, p_damage := 0.0, p_damageShield := 0.0, p_kbAngle := 0.0, p_kbAngleFixed := false, p_kbBase := 0.0, p_kbGrowth := 0.0, p_kbWeightSet := 0.0, p_hitGrounded := true, p_hitAirborne := true, p_isTrigger := false, p_triggerFuncs: Array[FighterFunction] = []):
	boneName = p_boneName
	hitboxID = p_hitboxID
	offset = p_offset
	radius = p_radius
	damage = p_damage
	damageShield = p_damageShield
	kbAngle = p_kbAngle
	kbAngleFixed = p_kbAngleFixed
	kbBase = p_kbBase
	kbGrowth = p_kbGrowth
	kbWeightSet = p_kbWeightSet
	HitGrounded = p_hitGrounded
	HitAirborne = p_hitAirborne
	IsTrigger = p_isTrigger
	TriggerFuncs = p_triggerFuncs
	curGlobalPosition = Vector3.ZERO
	oldGlobalPosition = Vector3.ZERO
	firstFrame = true
	

