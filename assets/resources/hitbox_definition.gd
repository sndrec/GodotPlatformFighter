extends Resource

class_name HitboxDefinition

@export var boneName: String = "HipN"

@export var hitboxID: int = 0

@export var offset: Vector3 = Vector3.ZERO

@export var radius: float = 1.0

@export var damage: float = 0.0

@export var damageShield: float = 0.0

@export var kbAngle: float = 0.0

@export var kbAngleFixed: bool = false

@export var kbBase: float = 0.0

@export var kbGrowth: float = 0.0

@export var kbWeightSet: float = 0.0

@export var HitAirborne: bool = true

@export var HitGrounded: bool = true

var firstFrame = true

var curGlobalPosition: Vector3 = Vector3.ZERO

var oldGlobalPosition: Vector3 = Vector3.ZERO

func _init(p_boneName := "HipN", p_hitboxID := 0, p_offset := Vector3.ZERO, p_radius := 1.0, p_damage := 0.0, p_damageShield := 0.0, p_kbAngle := 0.0, p_kbAngleFixed := false, p_kbBase := 0.0, p_kbGrowth := 0.0, p_kbWeightSet := 0.0, p_hitGrounded := true, p_hitAirborne := true):
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
	curGlobalPosition = Vector3.ZERO
	oldGlobalPosition = Vector3.ZERO
	firstFrame = true
	

