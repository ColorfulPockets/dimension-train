class_name Playspace extends Node2D

const CardBase = preload("res://Cards/CardBase.tscn")
const PlayerHand = preload("res://Cards/PlayerHand.gd")
const NORMAL_CURSOR = preload("res://Assets/Icons/cursor.png")

@onready var deckNames = ["Factory","Manufacture", "Mine", "Mine", "Mine", "Chop", "Chop", "Chop", "Build", "Build", "Build"]

@onready var viewportSize = Vector2(get_viewport().size)

@onready var cardOvalCenter = viewportSize* Vector2(0.5,0.975)
@onready var horizontalRadius = viewportSize.x*0.45
@onready var verticalRadius = viewportSize.y*0.2
var angle = deg_to_rad(90)
var ovalAngleVector = Vector2()

const HAND_LIMIT = 10
var cardsInHand:Array[CardBase] = []
var discardPile:Array[CardBase] = []
var discardPileIndexCounter = 0
var drawPile:Array[CardBase]		= []
var drawPileIndexCounter = 0

var numberOfFocusedCards = 0

@onready var terrain:Terrain = $Terrain
@onready var drawPileNode = $FixedElements/DrawPile
@onready var cardFunctions:CardFunctions = $CardFunctions


var shiftHeld = false
var building_rail = false

var endingTurn = false

signal handDrawn
signal cardFunctionHappening(happening)
signal terrainLoaded

# Called when the node enters the scene tree for the first time.
func _ready():
	#line.visible = false
	#line.z_index = 2
	#line.default_color = Color("#777777")
	#add_child(line)
	
	terrainLoaded.emit()
	
	var discardPileNode = $FixedElements/DiscardPile
	
	$FixedElements/DiscardPileCardCount.position = Global.DISCARD_PILE_POSITION + (discardPileNode.size*discardPileNode.scale / 2)
	$FixedElements/DrawPileCardCount.position = Global.DRAW_PILE_POSITION + (drawPileNode.size*drawPileNode.scale / 2)
	
	for cardName in deckNames:
		var new_card = CardBase.instantiate()
		new_card.CardName = cardName
		new_card.index = drawPileIndexCounter
		drawPileIndexCounter += 1
		$FixedElements/Cards.add_child(new_card)
		drawPile.append(new_card)
		
	drawPile.shuffle()
	
	terrain.building_rail.connect(func(): building_rail = true)
	terrain.rail_built.connect(func(_x): building_rail = false, 1)
	

func setMap(mapName):
	terrain.setMap(mapName)
	drawHand()

func drawHand():
	for i in range(5):
		await drawCard(drawPileNode.position, Vector2.ZERO)
		
	handDrawn.emit()

		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$FixedElements/DiscardPileCardCount.text = str(discardPile.size())
	$FixedElements/DrawPileCardCount.text = str(drawPile.size())

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
		card.reorganize()
		
var focusIndex = -1
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
	if cardHeldPointer == null:
		Global.cardFunctionStarted.emit()
		cardHeldPointer = pointer
		focusedCardPosition = cardPosition
		cardHeldIndex = index
		for i in range(cardsInHand.size()):
			if i != index:
				cardsInHand[i].other_card_pressed = true
			
		var discard_card = Global.FUNCTION_STATES.Unshift if not shiftHeld else Global.FUNCTION_STATES.Shift
		while discard_card == Global.FUNCTION_STATES.Unshift or discard_card == Global.FUNCTION_STATES.Shift:
			if discard_card == Global.FUNCTION_STATES.Shift:
				discard_card = await Callable(cardFunctions, cardHeldPointer.CardInfo[Global.CARD_FIELDS.BottomFunction]).call(cardHeldPointer.CardInfo)
			else:
				discard_card = await Callable(cardFunctions, cardHeldPointer.CardInfo[Global.CARD_FIELDS.TopFunction]).call(cardHeldPointer.CardInfo)
			
		if discard_card == Global.FUNCTION_STATES.Success:
			Stats.currentEnergy -= cardHeldPointer.CardInfo[Global.CARD_FIELDS.EnergyCost]
			cardDiscarded(cardHeldIndex)
		else:	
			cardReleased(cardHeldIndex)
		
		Global.cardFunctionEnded.emit()

func cardReleased(index):
	$Terrain.clearHighlights()
	for i in range(cardsInHand.size()):
		cardsInHand[i].other_card_pressed = false
		cardsInHand[i].card_pressed = false
		# mouseExited makes sure the card is unfocused and returns to hand
		cardsInHand[i].mouseExited(true)
		cardsInHand[i].manualFocusRetrigger()
	
	cardHeldPointer = null
	cardHeldIndex = -1
		
func cardDiscarded(index):
	$Terrain.clearHighlights()
	for i in range(cardsInHand.size()):
		cardsInHand[i].other_card_pressed = false
		cardsInHand[i].card_pressed = false
		# mouseExited makes sure the card is unfocused and returns to hand
		cardsInHand[i].mouseExited(true)
		cardsInHand[i].manualFocusRetrigger()
		if i < index:
			cardsInHand[i].ellipseAngle += deg_to_rad(5)
		elif i > index:
			cardsInHand[i].ellipseAngle -= deg_to_rad(5)
		
		cardsInHand[i].reorganize()
	var card_discarded = cardsInHand.pop_at(index)
	discardPile.append(card_discarded)
	card_discarded.index = discardPileIndexCounter
	discardPileIndexCounter += 1
	card_discarded.discard()
	angle -= deg_to_rad(5)
	for i in range(cardsInHand.size()):
		cardsInHand[i].index = i
	
	card_discarded.mousedOver = false
	
	cardHeldPointer = null
	cardHeldIndex = -1

func _input(event):
	if event is InputEventMouseMotion:
		if cardHeldIndex > -1:
			if shiftHeld:
				Input.set_custom_mouse_cursor(cardHeldPointer.CardInfo[Global.CARD_FIELDS.BottomMousePointer], 0, cardHeldPointer.CardInfo[Global.CARD_FIELDS.BottomMousePointer].get_size()/2)
			else:
				Input.set_custom_mouse_cursor(cardHeldPointer.CardInfo[Global.CARD_FIELDS.TopMousePointer], 0, cardHeldPointer.CardInfo[Global.CARD_FIELDS.TopMousePointer].get_size()/2)
			if ((cardHeldPointer.bottomTargetArea != null) if shiftHeld else (cardHeldPointer.topTargetArea != null)):
				terrain.highlightCells(event.position, cardHeldPointer.bottomTargetArea if shiftHeld else cardHeldPointer.topTargetArea)
		else:
			Input.set_custom_mouse_cursor(NORMAL_CURSOR,0,NORMAL_CURSOR.get_size()/2)
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var fake_mouse_motion = InputEventMouseMotion.new()
				fake_mouse_motion.position = get_viewport().get_mouse_position()
				_input(fake_mouse_motion)
	
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
				
		if event.key_label == KEY_E:
			if !event.pressed and cardHeldPointer == null:
				endTurn()
		
		if event.key_label == KEY_ESCAPE:
			if event.pressed:
				# Fake mouse motion tells the tilemap to redraw the highlight
				var fake_mouse_motion = InputEventMouseMotion.new()
				fake_mouse_motion.position = get_viewport().get_mouse_position()
				_input(fake_mouse_motion)
				
				

func endTurn():
	if !endingTurn:
		if focusIndex != -1:
			for card in cardsInHand:
				card.mouseExited(true)
		endingTurn = true
		await terrain.advanceTrain()
		while cardsInHand.size() > 0:
			cardDiscarded(0)
			await get_tree().create_timer(0.05).timeout
		await get_tree().create_timer(0.25).timeout
		drawHand()
		Stats.currentEnergy = Stats.maxEnergy
		await handDrawn
		endingTurn = false
	
	
		

func drawCard(fromPosition, fromScale):
	if drawPile.size() < 1:
		for card in discardPile:
			card.moveToDrawPile()
			card.index = drawPileIndexCounter
			drawPileIndexCounter += 1
			await get_tree().create_timer(0.05).timeout
			drawPile.append(card)
		drawPile.shuffle()
		discardPile = []
	if drawPile.size() < 1 or cardsInHand.size() >= HAND_LIMIT:
		return
	var new_card = drawPile.pop_front()
	new_card.card_pressed = false
	new_card.targetscale = CARDSIZE / new_card.size
	
	new_card.scale = fromScale
	
	new_card.position = fromPosition
	new_card.targetpos = posForAngle(angle)
	
	new_card.rotation = 0
		# This lets the cards rotate a little bit, but still remain mostly upright.
	new_card.targetrot = (-angle + deg_to_rad(90))*CARD_ANGLE
	
	new_card.state = Global.CARD_STATES.MoveDrawnCardToHand
	reorganizeHand()
	
	# Tell the card which number it is in the hand
	new_card.index = cardsInHand.size()
	new_card.ellipseAngle = angle
	cardsInHand.append(new_card)
	
	await get_tree().create_timer(0.05).timeout
	
	angle += deg_to_rad(5)
	
