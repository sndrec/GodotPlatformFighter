@tool
extends Node3D

class_name Hurtbox

var HitboxReady = false

var boneName: String = "":
	set(new_name):
		boneName = new_name
		if !HitboxReady:
			return
		var skeleton = get_parent() as Skeleton3D
		if skeleton.find_bone(new_name) > -1:
			boneID = skeleton.find_bone(new_name)
			print("Valid bone.")
		else:
			print("Invalid bone name!")

var boneID = -2

var startOffset: Vector3 = Vector3.ZERO

var endOffset: Vector3 = Vector3.ZERO

var radius: float = 10.0

var angle = 0.0

var isHitbox = false

var capsuleColor: Color


# Called when the node enters the scene tree for the first time.
func _ready():
	var HurtboxHead = $HurtboxHead as MeshInstance3D
	var HurtboxMiddle = $HurtboxMiddle as MeshInstance3D
	var HurtboxTail = $HurtboxTail as MeshInstance3D
	HitboxReady = true
	if !Engine.is_editor_hint():
		HurtboxHead.queue_free()
		HurtboxMiddle.queue_free()
		HurtboxTail.queue_free()
		return
	var skeleton = get_parent() as Skeleton3D
	if skeleton:
		boneID = skeleton.find_bone(boneName)
	position_debug_helpers()

func position_debug_helpers_simple() -> void:
	var HurtboxHead = $HurtboxHead as MeshInstance3D
	var HurtboxMiddle = $HurtboxMiddle as MeshInstance3D
	var HurtboxTail = $HurtboxTail as MeshInstance3D
	HurtboxHead.global_position = startOffset
	HurtboxTail.global_position = endOffset
	HurtboxMiddle.global_position = (startOffset + endOffset) * 0.5
	
	HurtboxHead.quaternion = Quaternion(Vector3(0, -1, 0), (HurtboxTail.position - HurtboxHead.position).normalized())
	HurtboxTail.quaternion = Quaternion(Vector3(0, -1, 0), (HurtboxHead.position - HurtboxTail.position).normalized())
	if HurtboxHead.position == HurtboxTail.position:
		HurtboxTail.quaternion = Quaternion.from_euler(Vector3(0, 0, PI))
		HurtboxHead.quaternion = Quaternion.from_euler(Vector3(0, 0, 0))
		
	if HurtboxHead.position.x == 0 and HurtboxHead.position.z == 0 and HurtboxTail.position.x == 0 and HurtboxTail.position.z == 0:
		if HurtboxHead.position.y > HurtboxTail.position.y:
			HurtboxTail.quaternion = Quaternion.from_euler(Vector3(0, 0, PI))
			HurtboxHead.quaternion = Quaternion.from_euler(Vector3(0, 0, 0))
		else:
			HurtboxTail.quaternion = Quaternion.from_euler(Vector3(0, 0, 0))
			HurtboxHead.quaternion = Quaternion.from_euler(Vector3(0, 0, PI))
		
	HurtboxMiddle.quaternion = HurtboxHead.quaternion
	
	HurtboxHead.scale = Vector3(radius * 2, radius * 2, radius * 2)
	HurtboxTail.scale = Vector3(radius * 2, radius * 2, radius * 2)
	HurtboxMiddle.scale = Vector3(radius * 2, (HurtboxTail.position - HurtboxHead.position).length(), radius * 2)

func position_debug_helpers() -> void:
	if boneID == -2:
		position_debug_helpers_simple()
		return
	var skeleton = get_parent() as Skeleton3D
	var HurtboxHead = $HurtboxHead as MeshInstance3D
	var HurtboxMiddle = $HurtboxMiddle as MeshInstance3D
	var HurtboxTail = $HurtboxTail as MeshInstance3D
	if !skeleton:
		return
	if boneID == -1:
		queue_free()
		return
	var bonePose = skeleton.get_bone_global_pose(boneID)
	position = Vector3(0,0,0)
	rotation = Vector3(0,0,0)
	
	var tempStart = startOffset
	var tempEnd = endOffset
	
	tempStart = bonePose * tempStart
	tempEnd = bonePose * tempEnd
	HurtboxHead.position = tempStart
	HurtboxTail.position = tempEnd
	HurtboxMiddle.position = (tempStart + tempEnd) * 0.5
	
	if isHitbox:
		HurtboxHead.global_position = startOffset
		HurtboxTail.global_position = endOffset
		HurtboxMiddle.global_position = (startOffset + endOffset) * 0.5
	
	HurtboxHead.quaternion = Quaternion(Vector3(0, -1, 0), (HurtboxTail.position - HurtboxHead.position).normalized())
	HurtboxTail.quaternion = Quaternion(Vector3(0, -1, 0), (HurtboxHead.position - HurtboxTail.position).normalized())
	if HurtboxHead.position == HurtboxTail.position:
		HurtboxTail.quaternion = Quaternion.from_euler(Vector3(0, 0, PI))
		HurtboxHead.quaternion = Quaternion.from_euler(Vector3(0, 0, 0))
		
	if HurtboxHead.position.x == 0 and HurtboxHead.position.z == 0 and HurtboxTail.position.x == 0 and HurtboxTail.position.z == 0:
		if HurtboxHead.position.y > HurtboxTail.position.y:
			HurtboxTail.quaternion = Quaternion.from_euler(Vector3(0, 0, PI))
			HurtboxHead.quaternion = Quaternion.from_euler(Vector3(0, 0, 0))
		else:
			HurtboxTail.quaternion = Quaternion.from_euler(Vector3(0, 0, 0))
			HurtboxHead.quaternion = Quaternion.from_euler(Vector3(0, 0, PI))
		
	HurtboxMiddle.quaternion = HurtboxHead.quaternion
	
	var trueRadius = radius * (1 / skeleton.get_parent().scale.x)
	
	HurtboxHead.scale = Vector3(trueRadius * 2, trueRadius * 2, trueRadius * 2)
	HurtboxTail.scale = Vector3(trueRadius * 2, trueRadius * 2, trueRadius * 2)
	HurtboxMiddle.scale = Vector3(trueRadius * 2, (HurtboxTail.position - HurtboxHead.position).length(), trueRadius * 2)
	
	if isHitbox:
		var dir = FHelp.Vec2to3(Vector2.from_angle(angle))
		DebugDraw.draw_arrow_line(skeleton.to_global(HurtboxHead.position), skeleton.to_global(HurtboxHead.position) + (dir * radius), Color(1, 1, 1), 0.1, false, 0.016666)

func _process(delta: float) -> void:
	position_debug_helpers()
