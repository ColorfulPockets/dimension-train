extends TextureButton

@onready var PLAYSPACE : Playspace = $"../.."
var drawingHand = false
var hoverTexture = null
var clickedTexture = null
var cardFunctionHappening = false
var overlayShowing = false

# Called when the node enters the scene tree for the first time.
func _ready():
	position = Global.END_TURN_BUTTON_POSITION
	PLAYSPACE.handDrawn.connect(func(): drawingHand = false; enableButton())
	Global.cardFunctionStarted.connect(func(): cardFunctionHappening = true; disableButton())
	Global.cardFunctionEnded.connect(func(): cardFunctionHappening = false; enableButton())
	Global.overlayShowing.connect(func(): overlayShowing = true; disableButton())
	Global.overlayHidden.connect(func(): overlayShowing = false; enableButton())
	hoverTexture = texture_hover
	clickedTexture = texture_pressed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func enableButton():
	texture_pressed = clickedTexture
	texture_hover = hoverTexture

func disableButton():
	texture_pressed = texture_normal
	texture_hover = texture_normal

func _pressed():
	if not drawingHand and not cardFunctionHappening and not overlayShowing:
		PLAYSPACE.numCardsToSelect = 4
		PLAYSPACE.selectingCards = true
		return
		
		drawingHand = true
		texture_pressed = texture_normal
		texture_hover = texture_normal
		PLAYSPACE.endTurn()
