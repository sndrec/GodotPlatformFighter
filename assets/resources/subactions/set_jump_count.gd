@tool

class_name SetJumpCount extends Subaction

var SubactionName = "Set Jump Count"

@export var jumps : int = 0

func _execute(inFt: Fighter) -> void:
	inFt.jumps = jumps
