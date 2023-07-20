@tool

class_name ClearHitboxByID extends Subaction

var SubactionName = "Clear Hitbox by ID"

@export var ID_To_Clear: int = 0

func _execute (inFighter: Fighter) -> void:
	for i in range(inFighter.ActiveHitboxes.size()):
		if inFighter.ActiveHitboxes[i].hitboxID == ID_To_Clear:
			inFighter.ActiveHitboxes.remove_at(i)
			break
	if inFighter.ActiveHitboxes.size() == 0:
		inFighter.clear_hitboxes()
