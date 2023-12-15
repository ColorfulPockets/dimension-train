class_name TrainSpeedContainer extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	position = Global.SPEED_CONTAINER_POSITION
	$MiddleBar.scale = size
	$SpeedLabel.position = size / 2 - $SpeedLabel.size / 2 + Vector2(0, 40)
	$TrainSpeedLabel.position = size / 2 - $TrainSpeedLabel.size / 2 + Vector2(0, -60)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$SpeedLabel.text = str(Stats.trainSpeed)
	$SpeedLabel.position = size / 2 - $SpeedLabel.size / 2 + Vector2(0, 40)
