@tool

class_name ChangeObjectVisibility extends Subaction

var SubactionName = "Change Object Visibility"

@export var objectName: String = ""

@export var visibility: bool = true

func _execute(inFt: Fighter) -> void:
	if inFt.FighterSkeleton.has_node(objectName):
		inFt.FighterSkeleton.get_node(objectName).visible = visibility
