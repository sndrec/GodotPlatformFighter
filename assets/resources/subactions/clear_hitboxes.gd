@tool

class_name ClearHitboxes extends Subaction

var SubactionName = "Clear Hitboxes"

func _execute (inFighter: Fighter) -> void:
	inFighter.clear_hitboxes()
