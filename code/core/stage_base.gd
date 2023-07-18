@tool

extends Node

class_name PFStage

@export var StageCollisionSegments: Array[StageCollisionSegment] = []

var fighters: Array[Fighter] = []

var cameraTransform: Transform3D = Transform3D.IDENTITY

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for seg in StageCollisionSegments:
		var start3D = Vector3(seg.startOffset.x, seg.startOffset.y, 0)
		var end3D = Vector3(seg.endOffset.x, seg.endOffset.y, 0)
		var midPoint = (start3D + end3D) * 0.5
		var dir = (end3D - start3D).normalized().rotated(Vector3(0, 0, 1), PI * 0.5)
		var lineColor = Color(1,1,1)
		if seg.colType == seg.collisionType.semisolid:
			lineColor = Color(0.2, 0.2, 1)
		DebugDraw.draw_line(start3D, end3D, lineColor, 0.016)
		DebugDraw.draw_arrow_line(midPoint, midPoint + dir * 8, lineColor, 1, true, 0.016)



func _save_state() -> Dictionary:
	return {
		cameraTransform = cameraTransform
	}
	

func _load_state(state: Dictionary) -> void:
	cameraTransform = state["cameraTransform"]
