@tool

class_name AutocancelEnabled extends Subaction

var SubactionName = "Autocancel"

## Used for aerial attacks.
## If enabled, character will enter regular Landing when touching the ground,
## instead of the aerial landing lag state.
@export var autocancelActive: bool = false

func _execute (inFt: Fighter) -> void:
	inFt.set_fighter_flag(1, autocancelActive)
