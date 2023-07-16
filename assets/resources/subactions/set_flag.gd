@tool

class_name SetFlag extends Subaction

var SubactionName = "Set Flag"

@export var flag: int = 0
@export var on: bool = false

func _execute(inFt: Fighter) -> void:
	inFt.set_fighter_flag(flag, on)
