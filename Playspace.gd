class_name Playspace extends Node2D

const CardBase = preload("res://Cards/CardBase.tscn")
const NORMAL_CURSOR = preload("res://Assets/Icons/cursor.png")

@onready var rewardScene:PackedScene = preload("res://reward.tscn")

@onready var deckNames = Stats.deck.duplicate()

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
var drawPile:Array[CardBase] = []
var drawPileIndexCounter = 0

var numberOfFocusedCards = 0

@onready var terrain:Terrain = $Terrain
@onready var drawPileNode = $FixedElements/DrawPile
@onready var cardFunctions:CardFunctions = $CardFunctions


var building_rail = false
var endingTurn = false

signal handDrawn
signal cardFunctionHappening(happening)
signal levelComplete()

# Called when the node enters the scene tree for the first time.
func _ready():
	# Passing the current node as the current playspace for Stats.
	# I couldn't figure out how to simply get a reference to this node, so I got the parent of one of its children.
	Stats.set_playspace(cardFunctions.get_parent())
	
	var discardPileNode = $FixedElements/DiscardPile
	
	$FixedElements/DiscardPileCardCount.position = Global.DISCARD_PILE_POSITION + (discardPileNode.size*discardPileNode.scale / 2)
	$FixedElements/DrawPileCardCount.position = Global.DRAW_PILE_POSITION + (drawPileNode.size*drawPileNode.scale / 2)
	
	for cardName in Stats.deck:
		var card = CardBase.instantiate()
		card.CardName = cardName
		$FixedElements/Cards.add_child(card)
		card.index = drawPileIndexCounter
		drawPileIndexCounter += 1
		drawPile.append(card)
		
	drawPile.shuffle()
	
	terrain.building_rail.connect(func(): building_rail = true)
	terrain.rail_built.connect(func(_x): building_rail = false, 1)
	
	drawHand()
	

func setMap(mapName):
	terrain.setMap(mapName)

func drawCardFromDeck():
	await drawCard(drawPileNode.position, Vector2.ZERO)

func drawHand():
	for i in range(5):
		await drawCardFromDeck()
		
	handDrawn.emit()

func spawnRewardBox(cell:Vector2i, location: Vector2):
	var rewardBox = rewardScene.instantiate()
	self.add_child(rewardBox)
	rewardBox.position = location
	rewardBox.setText(Global.getRewardText(cell))
	
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
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
func focusCard(newFocusIndex):
	self.focusIndex = newFocusIndex
	for i in range(cardsInHand.size()):
		if i != focusIndex:
			cardsInHand[i].updateFocusIndex(focusIndex)
	
		
func unFocus(index):
	if index == focusIndex:
		focusCard(-1)
		return true
	else:
		return false

var selectingCards = false
var selectedCards:Array = []
var numCardsToSelect = 0
var numCardsSelected = 0
func cardSelected(index, cardPosition, pointer:CardBase):
	if pointer.state == Global.CARD_STATES.InSelection:
		selectedCards.remove_at(selectedCards.find(pointer))
		for i in range(selectedCards.size()):
			selectedCards[i].index = i
			# Using moveToSelection to rearrange within the selection
			selectedCards[i].moveToSelection()
		pointer.removeFromSelection()
		# drawCard just actually moves a card from a given position and scale and adds it to the hand
		drawCard(pointer.position, pointer.scale, pointer)
		numCardsSelected -= 1
	elif numCardsSelected < numCardsToSelect:
		#Add to selection
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
		var card_selected = cardsInHand.pop_at(index)
		selectedCards.append(card_selected)
		angle -= deg_to_rad(5)
		for i in range(cardsInHand.size()):
			cardsInHand[i].index = i
		for i in range(selectedCards.size()):
			selectedCards[i].index = i
			# Using moveToSelection to rearrange within the selection
			selectedCards[i].moveToSelection()
		card_selected.mousedOver = false
		numCardsSelected += 1
	else:
		pointer.card_pressed = false

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
			
		var discard_card = Global.FUNCTION_STATES.Waiting
		while discard_card == Global.FUNCTION_STATES.Waiting:
			discard_card = await Callable(cardFunctions, cardHeldPointer.CardInfo[Global.CARD_FIELDS.Function]).call(cardHeldPointer.CardInfo)
			
		if ("AutoManufacture" in Stats.powersInPlay) and (discard_card == Global.FUNCTION_STATES.Success or discard_card == Global.FUNCTION_STATES.Power):
			cardFunctions.Manufacture({Global.CARD_FIELDS.Arguments: {"Manufacture": 2}}, false)
		if discard_card == Global.FUNCTION_STATES.Success:
			Stats.currentEnergy -= cardHeldPointer.CardInfo[Global.CARD_FIELDS.EnergyCost]
			cardDiscarded(cardHeldIndex)
		elif discard_card == Global.FUNCTION_STATES.Power:
			Stats.currentEnergy -= cardHeldPointer.CardInfo[Global.CARD_FIELDS.EnergyCost]
			cardPlayedAsPower(cardHeldIndex)
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
		
func cardPlayedAsPower(index):
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
	card_discarded.index = discardPileIndexCounter
	card_discarded.playAsPower()
	angle -= deg_to_rad(5)
	for i in range(cardsInHand.size()):
		cardsInHand[i].index = i
	
	cardHeldPointer = null
	cardHeldIndex = -1

func _input(event):
	if event is InputEventMouseMotion:
		if cardHeldIndex > -1:
			Input.set_custom_mouse_cursor(cardHeldPointer.CardInfo[Global.CARD_FIELDS.MousePointer], 0, cardHeldPointer.CardInfo[Global.CARD_FIELDS.MousePointer].get_size()/2)
			if cardHeldPointer.targetArea != null:
				terrain.highlightCells(event.position, cardHeldPointer.targetArea)
		else:
			Input.set_custom_mouse_cursor(NORMAL_CURSOR,0,NORMAL_CURSOR.get_size()/2)
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var fake_mouse_motion = InputEventMouseMotion.new()
				fake_mouse_motion.position = get_viewport().get_mouse_position()
				_input(fake_mouse_motion)
	
	if event is InputEventKey:
				
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
		await terrain.enemyTurn()
		while cardsInHand.size() > 0:
			cardDiscarded(0)
			await get_tree().create_timer(0.05).timeout
		await get_tree().create_timer(0.25).timeout
		drawHand()
		Stats.currentEnergy = Stats.maxEnergy
		await handDrawn
		endingTurn = false
	
	
		

func drawCard(fromPosition, fromScale, new_card:CardBase = null):
	if new_card == null:
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
		new_card = drawPile.pop_front()
		new_card.moveTime = new_card.DRAWTIME
	
	new_card.card_pressed = false
	new_card.targetscale = CARDSIZE / new_card.size
	new_card.inSelectionScale = CARDSIZE / new_card.size
	
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
	
