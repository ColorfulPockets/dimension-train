class_name Speedometer extends Panel

const LR_MARGINS = 30
const SPACING = 50
var speedLabels:Array = []
const currentSpeedScale = 1.5
const firstPos = Vector2(LR_MARGINS,0)
# Called when the node enters the scene tree for the first time.
func _ready():
	modulate.a = 0
	get_node("../SpeedLabel").modulate.a = 0

const FADE_TIME = 0.25
const INITIAL_FADE_TIME = 1
const MOVE_TIME = 0.5
func populateSpeedometer():
	modulate.a = 0
	for i in range(9):
		var speedLabel = Label.new()
		speedLabels.append(speedLabel)
		speedLabel.add_theme_font_size_override("font_size", 70)
		speedLabel.position = firstPos
		add_child(speedLabel)
		
	speedLabels[0].scale *= currentSpeedScale
	Global.fadeInNode(self, INITIAL_FADE_TIME)
	Global.fadeInNode(get_node("../SpeedLabel"), INITIAL_FADE_TIME)

func removeSpeedometer():
	Global.fadeOutNode(get_node("../SpeedLabel"), INITIAL_FADE_TIME)
	await Global.fadeOutNode(self, INITIAL_FADE_TIME)
	speedLabels.clear()

func progressTurn():
	var currentSpeedLabel = speedLabels.pop_front()
	Stats.progressTurn()
	await Global.fadeOutNode(currentSpeedLabel, FADE_TIME)
	Global.moveNodeLocalFrame(speedLabels[0], firstPos, MOVE_TIME)
	Global.scaleNode(speedLabels[0], currentSpeedScale*Vector2(1,1), MOVE_TIME)
	
	var speedLabel = Label.new()
	speedLabels.append(speedLabel)
	speedLabel.add_theme_font_size_override("font_size", 70)
	speedLabel.text = "0"
	speedLabel.position = firstPos
	add_child(speedLabel)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for i in range(speedLabels.size()):
		var speedLabel = speedLabels[i]
		speedLabel.text = str(Stats.getSpeedForTurn(i))
		if i == 0: continue
		var prevSpeedLabel = speedLabels[i-1]
		speedLabel.position.x = SPACING + prevSpeedLabel.position.x + (prevSpeedLabel.size.x * prevSpeedLabel.scale.x)
		var rightSide = speedLabel.position.x + speedLabel.size.x*speedLabel.scale.x
		var distanceFromContainerEdge = size.x*scale.x - rightSide
		var portion_in = distanceFromContainerEdge / LR_MARGINS
		portion_in = clamp(portion_in, 0, 1)	
		speedLabel.self_modulate.a = portion_in
