extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	position = Global.SPEED_CONTAINER_POSITION + $"../TrainSpeedContainer".size*Vector2(0,1)
	$MiddleBar.scale = size
	$NextSpeedLabel.position = size / 2 - $NextSpeedLabel.size / 2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	#$NextSpeedLabel.text = "Next: " + str(Stats.nextTrainSpeed)
	#$NextSpeedLabel.position = size / 2 - $NextSpeedLabel.size / 2
