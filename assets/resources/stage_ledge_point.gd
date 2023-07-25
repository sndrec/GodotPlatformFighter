class_name StageLedgePoint extends Resource

enum LedgeDir {
	LEFT = -1,
	RIGHT = 1
}

@export var pos: Vector2

@export var dir: LedgeDir = LedgeDir.RIGHT

func _init(p_pos = Vector2(0,0), p_dir = LedgeDir.RIGHT):
	pos = p_pos
	dir = p_dir
