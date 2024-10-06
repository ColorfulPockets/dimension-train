extends Panel

const SPACING = 50
var speedLabels = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var speedLabelPosition = Vector2(0,0)
	for i in range(6):
		var speedLabel = Label.new()
		speedLabels.append(speedLabel)
		speedLabel.add_theme_font_size_override("font_size", 70)
		speedLabel.text = "0"
		speedLabel.position = speedLabelPosition
		add_child(speedLabel)
		speedLabelPosition.x += speedLabel.size.x + 50
		
	speedLabels[0].scale *= 2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for i in range(speedLabels.size()):
		if i == 0: continue
		var prevSpeedLabel = speedLabels[i-1]
		var speedLabel = speedLabels[i]
		speedLabel.position.x = SPACING + prevSpeedLabel.position.x + prevSpeedLabel.size.x * prevSpeedLabel.scale.x
