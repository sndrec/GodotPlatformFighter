extends Resource

class_name StageCollisionSegment

enum collisionType {solid, semisolid}

@export var parent: Node3D
@export var startOffset: Vector2
@export var endOffset: Vector2
@export var friction: float
@export var colType: collisionType

func _init(p_parent = null, p_startOffset = Vector2.ZERO, p_endOffset = Vector2.ZERO, p_friction = 1):
	parent = p_parent
	startOffset = p_startOffset
	endOffset = p_endOffset
	friction = p_friction
