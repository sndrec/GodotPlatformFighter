@tool

class_name SetInterruptable extends Subaction

var SubactionName = "Can Interrupt"

@export var canInterrupt : bool = true

func _execute(inFt: Fighter) -> void:
	if canInterrupt:
		inFt.InterruptableTime = 0
	else:
		inFt.InterruptableTime = 32768
