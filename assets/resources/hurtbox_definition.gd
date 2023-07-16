extends Resource

class_name HurtboxDefinition

@export var boneName: String

@export var startOffset: Vector3

@export var endOffset: Vector3

@export var radius: float

func _init(p_boneName = "HipN", p_startOffset = Vector3.ZERO, p_endOffset = Vector3.ZERO, p_radius = 1):
	boneName = p_boneName
	startOffset = p_startOffset
	endOffset = p_endOffset
	radius = p_radius

