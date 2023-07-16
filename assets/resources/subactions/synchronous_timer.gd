@tool

class_name SynchronousTimer extends Subaction

var SubactionName = "Synchronous Timer"

@export var frames: int = 0

func _execute (inFt: Fighter) -> void:
	print("Timer!")
