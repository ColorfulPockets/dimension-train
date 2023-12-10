extends Node2D

const CardBase = preload("res://Cards/CardBase.tscn")
const PlayerHand = preload("res://Cards/PlayerHand.gd")

@onready var deck = ["Mine", "Chop", "Transport", "Build", "Mine", "Chop", "Transport", "Build", "Mine", "Chop", "Transport", "Build"]

@onready var viewportSize = Vector2(get_viewport().size)

@onready var cardOvalCenter = viewportSize* Vector2(0.5,0.975)
@onready var horizontalRadius = viewportSize.x*0.45
@onready var verticalRadius = viewportSize.y*0.2
var angle = deg_to_rad(90)
var ovalAngleVector = Vector2()

# Each card is represented as [card_ref, standard_angle]
var cardsInHand = []

var numberOfFocusedCards = 0

@onready var line = $FixedElements/CardTargetLine
@onready var terrain = $Terrain
@onready var cardFunctions = load("res://CardFunctions.gd").new(terrain)

# Called when the node enters the scene tree for the first time.
func _ready():
	line.visible = false
	line.z_index = 2
	line.default_color = Color("#777777")
	add_child(line)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

const CARDSIZE = Vector2(750/2,1050/2)
# How much the cards should be rotated compared to their position on the ellipse
const CARD_ANGLE = float(1)/float(4)

func posForAngle(angle):
	ovalAngleVector = Vector2(horizontalRadius * cos(angle), - verticalRadius * sin(angle))
	return cardOvalCenter + ovalAngleVector
	
func rotForAngle(angle):
	return (-angle + deg_to_rad(90))*CARD_ANGLE

func reorganizeHand():
	for card in cardsInHand:
		card.ellipseAngle -= deg_to_rad(5)
		card.targetpos = posForAngle(card.ellipseAngle)
		card.targetrot = rotForAngle(card.ellipseAngle)
		card.state = Global.CARD_STATES.ReorganizeHand
		
var focusIndex = 0
# Tells each card where the focus is so they can move out of the way
# -1 is signal for no card focused
func focusCard(focusIndex):
	self.focusIndex = focusIndex
	for i in range(cardsInHand.size()):
		if i != focusIndex:
			cardsInHand[i].updateFocusIndex(focusIndex)
	
		
func unFocus(index):
	if index == focusIndex:
		focusCard(-1)
		return true
	else:
		return false

var cardHeldIndex = -1
var cardHeldPointer = null
var focusedCardPosition = Vector2()

func cardPressed(index, cardPosition, pointer):
	cardHeldPointer = pointer
	focusedCardPosition = cardPosition
	cardHeldIndex = index
	for i in range(cardsInHand.size()):
		if i != index:
			cardsInHand[i].other_card_pressed = true

func cardReleased(index):
	cardHeldPointer = null
	cardHeldIndex = -1
	line.visible = false
	$Terrain.clearHighlights()
	for i in range(cardsInHand.size()):
		cardsInHand[i].other_card_pressed = false
		cardsInHand[i].card_pressed = false
		# mouseExited makes sure the card is unfocused and returns to hand
		cardsInHand[i].mouseExited(true)
		cardsInHand[i].manualFocusRetrigger()

#func getLinePoints(points:Array[Vector2]):
	#var curve = Curve2D.new()
	#
	#points.push_front(points[0])
	#points.push_back(points[-1])
	#
	#for i in range(1,points.size()-1):
		#curve.add_point(points[i], (points[i]-points[i-1])/2, (points[i+1]-points[i])/2)
	#
	#
	#return curve.get_baked_points()
	
var shiftHeld = false

func _input(event):
	if event is InputEventMouseMotion and cardHeldIndex > -1:
		if ((cardHeldPointer.bottomTargetArea != null) if shiftHeld else (cardHeldPointer.topTargetArea != null)):
			line.visible = true
			line.points = PackedVector2Array([focusedCardPosition, event.position])
			terrain.highlightCells(event.position, cardHeldPointer.bottomTargetArea if shiftHeld else cardHeldPointer.topTargetArea)
		
	if event is InputEventKey:
		if event.key_label == KEY_SHIFT:
			if event.pressed:
				shiftHeld = true
				# Fake mouse motion tells the tilemap to redraw the highlight
				var fake_mouse_motion = InputEventMouseMotion.new()
				fake_mouse_motion.position = get_viewport().get_mouse_position()
				_input(fake_mouse_motion)
			else:
				shiftHeld = false
				var fake_mouse_motion = InputEventMouseMotion.new()
				fake_mouse_motion.position = get_viewport().get_mouse_position()
				_input(fake_mouse_motion)
			
	if event is InputEventMouseButton and cardHeldIndex > -1:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if not event.pressed:
				if shiftHeld:
					Callable(cardFunctions, cardHeldPointer.CardInfo[Global.CARD_FIELDS.BottomFunction]).call(terrain.highlighted_tiles)
				else:
					Callable(cardFunctions, cardHeldPointer.CardInfo[Global.CARD_FIELDS.TopFunction]).call(terrain.highlighted_tiles)
					
				cardReleased(cardHeldIndex)

func drawCard(fromPosition, fromScale):
	var new_card = CardBase.instantiate()
	new_card.CardName = deck[0]
	new_card.targetscale = CARDSIZE / new_card.size
	
	new_card.scale = fromScale
	
	new_card.position = fromPosition
	new_card.targetpos = posForAngle(angle)
	
	new_card.rotation = 0
		# This lets the cards rotate a little bit, but still remain mostly upright.
	new_card.targetrot = (-angle + deg_to_rad(90))*CARD_ANGLE
	
	$FixedElements/Cards.add_child(new_card)
	new_card.state = Global.CARD_STATES.MoveDrawnCardToHand
	reorganizeHand()
	
	# Tell the card which number it is in the hand
	new_card.index = cardsInHand.size()
	new_card.ellipseAngle = angle
	cardsInHand.append(new_card)
	deck.pop_front()
	
	angle += deg_to_rad(5)
