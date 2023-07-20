extends GridContainer

var stage: PFStage

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func update_player_percent(inFt: Fighter) -> void:
	var desiredID = 0
	for i in range(stage.fighters.size()):
		if stage.fighters[i] == inFt:
			desiredID = i
			break
	if desiredID == 0:
		%P1Percent.text = str(floor(inFt.percentage)) + "%"
	if desiredID == 1:
		%P2Percent.text = str(floor(inFt.percentage)) + "%"
