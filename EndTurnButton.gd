extends TextureButton

@onready var PLAYSPACE = $"../.."
var drawingHand = false
var hoverTexture = null
var clickedTexture = null
var cardFunctionHappening = false

# Called when the node enters the scene tree for the first time.
func _ready():
	position = Global.END_TURN_BUTTON_POSITION
	PLAYSPACE.handDrawn.connect(func(): drawingHand = false; enableButton())
	Global.cardFunctionStarted.connect(func(): cardFunctionHappening = true; disableButton())
	Global.cardFunctionEnded.connect(func(): cardFunctionHappening = false; enableButton())
	hoverTexture = texture_hover
	clickedTexture = texture_pressed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func enableButton():
	texture_pressed = clickedTexture
	texture_hover = hoverTexture

func disableButton():
	texture_pressed = texture_normal
	texture_hover = texture_normal

func _pressed():
	if not drawingHand and not cardFunctionHappening:
		drawingHand = true
		texture_pressed = texture_normal
		texture_hover = texture_normal
		PLAYSPACE.endTurn()
