extends Container

@onready var cdt = preload("res://CardDataTypes.gd").new()
@onready var types = cdt.CARD_TYPES
@onready var fields = cdt.CARD_FIELDS
@onready var states = cdt.CARD_STATES

@onready var CardDb = preload("res://CardDatabase.gd").new()

var CardName = "Chop"

@onready var CardInfo = CardDb.DATA[CardName]

@onready var CardImg = str("res://Assets/Icons/",CardInfo[0],".png")

@onready var state = states.InHand
var startpos = 0
var targetpos = 0
var startrot = 0
var targetrot = 0
var t = 0

var DRAWTIME = 0.1

# Called when the node enters the scene tree for the first time.
func _ready():
	$Icon.texture = load(CardImg)
	# Scale to 50px
	$Icon.scale *= 0.09766
	$Icon.position = Vector2(125,195)
	
	$TopText/TopText.text = CardInfo[fields.TopText]
	$BottomText/BottomText.text = CardInfo[fields.BottomText]
	$Name/Name.text = CardInfo[fields.Name]
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match state:
		states.InHand:
			pass
		states.InPlay:
			pass
		states.InMouse:
			pass
		states.FocusInHand:
			pass
		states.MoveDrawnCardToHand: # animate from deck to hand
			if t <= 1: # this is always a 1 because that's how interpolate assumes
				position = startpos.lerp(targetpos, t)
				rotation = startrot + (targetrot - startrot)*t
				t += delta/float(DRAWTIME)
			else:
				position = targetpos
				rotation = targetrot
				state = states.InHand
				t = 0
		states.ReOrganizeHand:
			pass
