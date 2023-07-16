@tool

class_name TurnAround extends Subaction

var SubactionName = "Turn"

func _execute (inFighter: Fighter) -> void:
	inFighter.facing *= -1
