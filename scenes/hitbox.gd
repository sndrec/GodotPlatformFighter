@tool
extends Node3D


class_name Hitbox

var Character

var boneID: int = 0

var startOffset: Vector3 = Vector3.ZERO

var radius: float = 10.0


# Called when the node enters the scene tree for the first time.
func _ready():
	var HitboxHead = $HitboxHead as MeshInstance3D
	var HitboxMiddle = $HitboxMiddle as MeshInstance3D
	var HitboxTail = $HitboxTail as MeshInstance3D
	if !Engine.is_editor_hint():
		HitboxHead.queue_free()
		HitboxMiddle.queue_free()
		HitboxTail.queue_free()
		return


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
