extends Resource

class_name HurtboxDefinition

@export var boneName: String

@export var startOffset: Vector3

@export var endOffset: Vector3

@export var radius: float

enum hurtboxBodyType {
	High,
	Middle,
	Low
}

enum hurtboxBodyState {
	Normal,
	Invincible,
	Intangible
}

@export var bodyType: hurtboxBodyType

@export var grabbable: bool

var bodyState: hurtboxBodyState = hurtboxBodyState.Normal

func _init(p_boneName = "HipN", p_startOffset = Vector3.ZERO, p_endOffset = Vector3.ZERO, p_radius = 1, p_bodyType = hurtboxBodyType.High, p_grabbable = true):
	boneName = p_boneName
	startOffset = p_startOffset
	endOffset = p_endOffset
	radius = p_radius
	bodyType = p_bodyType
	grabbable = p_grabbable

