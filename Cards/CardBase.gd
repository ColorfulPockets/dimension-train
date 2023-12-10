extends Container

@onready var types = Global.CARD_TYPES
@onready var fields = Global.CARD_FIELDS
@onready var states = Global.CARD_STATES

@onready var CardDb = preload("res://CardDatabase.gd").new()

var CardName = "Chop"

@onready var CardInfo = CardDb.DATA[CardName]

@onready var CardImg = str("res://Assets/Icons/",CardInfo[0],".png")

var topTargetArea = null
var bottomTargetArea = null

@onready var state = states.InHand
var startpos = Vector2()
var targetpos = Vector2()
var startrot = 0
var targetrot = 0
var startscale = Vector2()
var targetscale = Vector2()
var focuspos = Vector2()
var focusrot = 0
var focusscale = Vector2()
var t = 0

# Tracks where it is in the hand
var index = 0

# Tracks which card should be focused
var focusIndex = 0

var ellipseAngle = 0

var inHandPosition = Vector2()
var inHandScale = Vector2()
var inHandRotation = 0
var out_of_place = false
var currentPositionSet = false
const FOCUS_SCALE_AMOUNT = 1.5
var card_pressed = false
var other_card_pressed = false
var mousedOver = false

var DRAWTIME = 0.2
var REORGTIME = 0.1
var RETURNTOHANDTIME = 0.1
var FOCUSTIME = 0.1
var moveTime = 0.1

@onready var PLAYSPACE = $"../../.."

# Called when the node enters the scene tree for the first time.
func _ready():
	$Icon.texture = load(CardImg)
	# Scale to 50px
	$Icon.scale *= 0.09766
	$Icon.position = Vector2(125,195)
	
	$TopText/TopText.text = CardInfo[fields.TopText]
	$BottomText/BottomText.text = CardInfo[fields.BottomText]
	$Name/Name.text = CardInfo[fields.Name]
	
	if CardInfo.has(Global.CARD_FIELDS.TopTargetArea):
		topTargetArea = CardInfo[Global.CARD_FIELDS.TopTargetArea]
		bottomTargetArea = CardInfo[Global.CARD_FIELDS.BottomTargetArea]
		
	
	connect("mouse_entered",mouseEntered)
	connect("mouse_exited", mouseExited)

# When you release a card, other cards don't know if they should focus
func manualFocusRetrigger():
	if mousedOver:
		mouseEntered()

func mouseEntered():
	mousedOver = true
	if not other_card_pressed and not card_pressed:
		$HighlightBorder.visible = true
		out_of_place = true
		resetCurrentPosition()
		PLAYSPACE.focusCard(index)
		state = states.FocusInHand
	
func mouseExited(manuallyTriggered=false):
	if not manuallyTriggered:
		mousedOver = false
	if not card_pressed:
		# unFocus returns false if the current card isn't already focused
		if PLAYSPACE.unFocus(index) or manuallyTriggered:
			$HighlightBorder.visible = false
			out_of_place = true
			resetCurrentPosition()
			# Playspace.gd keeps a counter of how many focused cards there are.  If 0,
			# it sends all cards to InHand state.
			# unFocus tells it to decrement the counter
			state = states.InHand	

func updateFocusIndex(index):
	focusIndex = index
	out_of_place = true
	resetCurrentPosition()
	state = states.FocusOtherInHand

func resetCurrentPosition():
	if not currentPositionSet:
		startpos = position
		startrot = rotation
		startscale = scale
		currentPositionSet = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match state:
		states.InHand:
			z_index = 0
			if t <= 1 and out_of_place:
				position = startpos.lerp(inHandPosition, t)
				rotation = startrot + (inHandRotation - startrot)*t
				scale = startscale.lerp(inHandScale, t)
				t += delta/float(moveTime)
			else:
				t = 0
				position = inHandPosition
				rotation = inHandRotation
				scale = inHandScale
				out_of_place = false
				currentPositionSet = false
		states.FocusOtherInHand:
			z_index = 0
			moveTime = REORGTIME
			if focusIndex == -1:
				state = states.InHand
			else:
				var index_difference:float = index - focusIndex
				var newAngle = ellipseAngle+(deg_to_rad(2.5)*(1.0/(index_difference)))
				var focusOtherPos = PLAYSPACE.posForAngle(newAngle)
				var focusOtherRot = PLAYSPACE.rotForAngle(newAngle)
				if t <= 1 and out_of_place:
					position = startpos.lerp(focusOtherPos, t)
					rotation = startrot + (focusOtherRot - startrot)*t
					scale = startscale.lerp(inHandScale, t)
					t += delta/float(REORGTIME)
				else:
					out_of_place = false
					currentPositionSet = false
					position = focusOtherPos
					rotation = focusOtherRot
					scale = inHandScale
					t = 0
		states.FocusInHand:
			focuspos = Vector2(inHandPosition.x, get_viewport().size.y*0.97 - FOCUS_SCALE_AMOUNT*size.y)
			focusrot = 0
			focusscale = FOCUS_SCALE_AMOUNT*inHandScale
			z_index = 1
			moveTime = RETURNTOHANDTIME
			if t <= 1 and out_of_place:
				position = startpos.lerp(focuspos, t)
				rotation = startrot + (0 - startrot)*t
				scale = startscale.lerp(1.5*startscale, t)
				t += delta / float(FOCUSTIME)
			else:
				t = 0
				position = focuspos
				rotation = 0
				scale = FOCUS_SCALE_AMOUNT*inHandScale
				out_of_place = false
				currentPositionSet = false
		states.MoveDrawnCardToHand: # animate from deck to hand
			resetCurrentPosition()
			inHandPosition = targetpos
			inHandRotation = targetrot
			inHandScale = targetscale
			out_of_place = true
			moveTime = DRAWTIME
			state = states.InHand
		states.ReorganizeHand:
			resetCurrentPosition()
			inHandPosition = targetpos
			inHandRotation = targetrot
			inHandScale = targetscale
			moveTime = REORGTIME
			out_of_place = true
			state = states.InHand

func _input(event):
	if mousedOver:
		# Draw arrow with click and drag from card
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				card_pressed = true
				# Alert the playspace about which card has been clicked
				PLAYSPACE.cardPressed(index, focuspos + size/2, self)
