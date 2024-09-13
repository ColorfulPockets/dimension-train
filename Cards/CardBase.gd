class_name CardBase extends Control

signal rewardSelected(card)
signal bought(card)
signal removeSelected(card)

@onready var types = Global.CARD_TYPES
@onready var fields = Global.CARD_FIELDS
@onready var states = Global.CARD_STATES


@onready var current_playspace:Playspace = Stats.current_playspace
@onready var OVERLAY_MANAGER = $"../../../../../FixedElements/DarkenedBackground"

var CardName = "Harvest"

@onready var CardInfo = Global.CardDb.DATA[CardName]

@onready var CardImg = str("res://Assets/Icons/",CardInfo[0],".png")

@onready var state = states.InHand
var startpos = Vector2()
var targetpos = Vector2()
var startrot = 0
var targetrot = 0
var startA = 1.0
var startscale = Vector2()
var targetscale = Vector2()
var focuspos = Vector2()
var focusrot = 0
var focusscale = Vector2()
var t = 0

const DISCARD_PILE_ROTATION = 0
const DISCARD_PILE_SCALE = Vector2(0.2,0.2)
const OVERLAY_SCALE = Vector2(1.75,1.75)

# Tracks where it is in the hand
var index = 0

# Tracks which card should be focused
var focusIndex = 0

var ellipseAngle = 0

var inHandPosition = Vector2()
var inHandScale = Vector2()
var inHandRotation = 0
var inSelectionPosition = Vector2()
var inSelectionScale = Vector2.ONE
var inSelectionRotation = 0
const SELECTION_MARGIN = 150
const SELECTION_CENTER_POSITION = Vector2(1920, 700)
var out_of_place = false
var currentPositionSet = false
const FOCUS_SCALE_AMOUNT = 1.5
var card_pressed = false
var other_card_pressed = false
var mousedOver = false
var cardPileShowing = false
var inReward = false
var inShop = false
var price = 3
var inRemove = false

var DRAWTIME = 0.3
var REORGTIME = 0.15
var RETURNTOHANDTIME = 0.1
var FOCUSTIME = 0.1
var moveTime = 0.1

var selectingACard = false

var baseText:String

# Called when the node enters the scene tree for the first time.
func _ready():
	$HighlightBorder/MarginContainer/VBox/Image/VBoxContainer/Icon.texture = load(CardImg)
	
	baseText = CardInfo[fields.Text]
	replaceText()
	$HighlightBorder/MarginContainer/VBox/Name/HBoxContainer/Name.text = CardInfo[fields.Name]
	
	$HighlightBorder/MarginContainer/VBox/Name/HBoxContainer/EnergyCost.text = str(CardInfo[Global.CARD_FIELDS.EnergyCost])
		
	
	connect("mouse_entered",mouseEntered)
	connect("mouse_exited", mouseExited)
	
	Global.overlayShowing.connect(func(): cardPileShowing = true)
	Global.overlayHidden.connect(func(): cardPileShowing = false)
	
	if CardName in Global.rares:
		price = Global.RARE_PRICE
	elif CardName in Global.uncommons:
		price = Global.UNCOMMON_PRICE
		
	changeSize(null, 2)

func changeSize(newSize=null, numFramesToWait:int = 0):	
	if newSize != null:
		size = newSize
		
	pivot_offset = size/2
	
	for _i in range(numFramesToWait):
		await get_tree().process_frame
	var nameHeight = $HighlightBorder/MarginContainer/VBox/Name/HBoxContainer.size.y
	var nameLabel = $HighlightBorder/MarginContainer/VBox/Name/HBoxContainer/Name
	var energyCostLabel = $HighlightBorder/MarginContainer/VBox/Name/HBoxContainer/EnergyCost
	
	var bottomTextHeight = $HighlightBorder/MarginContainer/VBox/BottomText.size.y
	var bottomTextLabel = $HighlightBorder/MarginContainer/VBox/BottomText/BottomText
	
	var fontSize = 1
	while nameLabel.size.y < nameHeight * 0.67:
		fontSize += 1
		nameLabel.add_theme_font_size_override("font_size", fontSize)
		energyCostLabel.add_theme_font_size_override("font_size", fontSize)
		
	var fontSize2 = 1
	while bottomTextLabel.size.y < bottomTextHeight * 0.67 and fontSize2 <= fontSize:
		bottomTextLabel.add_theme_font_size_override("font_size", fontSize2)
		fontSize2 += 1

#GPT
func replaceText():
	var newText: String = baseText
	var pattern = RegEx.new()
	pattern.compile(r'TARGETAREA')
	var matches = pattern.search_all(baseText)
	for match in matches:
		var key = match.get_string(1)	# get the matched argument name
		var targetArea = CardInfo[Global.CARD_FIELDS.TargetArea]
		var replacement = str(targetArea.x) + "x" + str(targetArea.y)
		newText = baseText.replace("TARGETAREA", replacement)
	
	pattern = RegEx.new()
	pattern.compile(r'ARG(\w+)')
	matches = pattern.search_all(newText)
	for match in matches:
		var key = match.get_string(1)	# get the matched argument name
		if CardInfo[Global.CARD_FIELDS.Arguments].has(key):
			var argReplacement = str(CardInfo[Global.CARD_FIELDS.Arguments][key])
			newText = newText.replace("ARG" + key, argReplacement)
			
	$HighlightBorder/MarginContainer/VBox/BottomText/BottomText.text = newText

# Since the cards are children of Stats, we need to reset some variables when adding them to the playspace
func resetPlayspace():
	current_playspace = $"../../.."
	print("Playspace Reset")

# When you release a card, other cards don't know if they should focus
func manualFocusRetrigger():
	if mousedOver:
		mouseEntered()

func mouseEntered():
	if inReward or inShop or inRemove or (state == states.InSelection):
		$HighlightBorder.self_modulate.a = 1
		mousedOver = true
		return
	if cardPileShowing:
		return
	if card_pressed or current_playspace.endingTurn:
		return
	mousedOver = true
	if not other_card_pressed and not card_pressed:
		$HighlightBorder.self_modulate.a = 1
		out_of_place = true
		resetCurrentPosition()
		current_playspace.focusCard(index)
		state = states.FocusInHand
	
func mouseExited(manuallyTriggered=false):
	if inReward or inShop or inRemove or (state == states.InSelection):
		$HighlightBorder.self_modulate.a = 0
		mousedOver = false
		return
	if cardPileShowing:
		return
	if state == states.InDiscardPile or current_playspace.endingTurn:
		return
	if not manuallyTriggered:
		mousedOver = false
	if not card_pressed:
		# unFocus returns false if the current card isn't already focused
		if current_playspace.unFocus(index) or manuallyTriggered:
			$HighlightBorder.self_modulate.a = 0
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

func reorganize():
	resetCurrentPosition()
	inHandPosition = current_playspace.posForAngle(ellipseAngle)
	inHandRotation = current_playspace.rotForAngle(ellipseAngle)
	inHandScale = targetscale
	moveTime = REORGTIME
	out_of_place = true
	state = states.InHand

func discard():
	resetCurrentPosition()
	$HighlightBorder.self_modulate.a = 0
	out_of_place = true
	moveTime = DRAWTIME
	state = states.InDiscardPile

func playAsPower():
	resetCurrentPosition()
	$HighlightBorder.self_modulate.a = 0
	out_of_place = true
	moveTime = DRAWTIME
	state = states.InPower
	
func moveToDrawPile():
	resetCurrentPosition()
	visible = true
	out_of_place = true
	card_pressed = false
	other_card_pressed = false
	mousedOver = false
	moveTime = DRAWTIME
	state = states.InDrawPile

func moveToDeck():
	var global_pos = global_position
	top_level = true
	position = global_pos
	resetCurrentPosition()
	visible = true
	out_of_place = true
	card_pressed = false
	other_card_pressed = false
	mousedOver = false
	moveTime = DRAWTIME
	state = states.InDeck

func moveToOverlay():
	t = 0
	z_index = 13
	state = states.InOverlay
	scale = OVERLAY_SCALE
	rotation = 0
	fadeIn()

func moveToSelection():
	moveTime = REORGTIME
	t = 0
	z_index = 13
	var offset = (-float(current_playspace.selectedCards.size())/2.0 + index) * (size.x + SELECTION_MARGIN)
	inSelectionPosition = Vector2(offset, 0) + SELECTION_CENTER_POSITION
	state = states.InSelection
	resetCurrentPosition()
	out_of_place = true
	
func removeFromSelection():
	moveTime = REORGTIME
	# The rest of the work of moving it to the hand is done by the draw() function in Playspace
	$HighlightBorder.self_modulate.a = 0

func fadeIn():
	modulate.a8 = 0
	visible = true
	var steps = 20
	for i in range(steps):
		modulate.a8 += 255/steps
		await get_tree().create_timer(float(Global.FADE_TIME)/steps).timeout
	
	modulate.a8 = 255

func fadeOut():
	modulate.a8 = 255
	var steps = 20
	for i in range(steps):
		modulate.a8 -= 255/steps
		await get_tree().create_timer(float(Global.FADE_TIME)/steps).timeout
		
	visible = false
	modulate.a8 = 255

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match state:
		states.InOverlay:
			pass
		states.InDeck:
			z_index = 1
			if t <= 1 and out_of_place:
				position = startpos.lerp(Global.DECK_POSITION, t)
				rotation = startrot + (DISCARD_PILE_ROTATION - startrot)*t
				scale = startscale.lerp(DISCARD_PILE_SCALE, t)
				t += delta/float(moveTime)
			else:
				t = 0
				position = Global.DECK_POSITION
				rotation = DISCARD_PILE_ROTATION
				scale = DISCARD_PILE_SCALE
				visible = false
				out_of_place = false
				currentPositionSet = false
		states.InDrawPile:
			z_index = 1
			if t <= 1 and out_of_place:
				position = startpos.lerp(Global.DRAW_PILE_POSITION, t)
				rotation = startrot + (DISCARD_PILE_ROTATION - startrot)*t
				scale = startscale.lerp(DISCARD_PILE_SCALE, t)
				t += delta/float(moveTime)
			else:
				t = 0
				position = Global.DRAW_PILE_POSITION
				rotation = DISCARD_PILE_ROTATION
				scale = DISCARD_PILE_SCALE
				visible = false
				out_of_place = false
				currentPositionSet = false
		states.InDiscardPile:
			z_index = 1
			if t <= 1 and out_of_place:
				position = startpos.lerp(Global.DISCARD_PILE_POSITION, t)
				rotation = startrot + (DISCARD_PILE_ROTATION - startrot)*t
				scale = startscale.lerp(DISCARD_PILE_SCALE, t)
				t += delta/float(moveTime)
			else:
				t = 0
				position = Global.DISCARD_PILE_POSITION
				rotation = DISCARD_PILE_ROTATION
				scale = DISCARD_PILE_SCALE
				visible = false
				out_of_place = false
				currentPositionSet = false
		states.InPower:
			z_index = 1
			if t <= 1 and out_of_place:
				position = startpos.lerp(Global.POWER_POSITION, t)
				rotation = startrot + (DISCARD_PILE_ROTATION - startrot)*t
				scale = startscale.lerp(Vector2.ONE, t)
				modulate.a = startA + (0.0 - startA)*t
				t += delta/float(moveTime)
			else:
				t = 0
				position = Global.POWER_POSITION
				rotation = DISCARD_PILE_ROTATION
				scale = Vector2.ONE
				visible = false
				out_of_place = false
				currentPositionSet = false
				queue_free()
		states.InHand:
			visible = true
			z_index = index + 1
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
			z_index = index + 1
			moveTime = REORGTIME
			if focusIndex == -1:
				state = states.InHand
			else:
				var index_difference:float = index - focusIndex
				var newAngle = ellipseAngle+(deg_to_rad(2.5)*(1.0/(index_difference)))
				var focusOtherPos = current_playspace.posForAngle(newAngle)
				var focusOtherRot = current_playspace.rotForAngle(newAngle) 
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
			focuspos = Vector2(inHandPosition.x, get_viewport().size.y - 0.8*FOCUS_SCALE_AMOUNT*size.y)
			focusrot = 0
			focusscale = FOCUS_SCALE_AMOUNT*inHandScale
			z_index = 11
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
			state = states.InHand
		states.InSelection:
			visible = true
			if t <= 1 and out_of_place:
				position = startpos.lerp(inSelectionPosition, t)
				rotation = startrot + (inSelectionRotation - startrot)*t
				scale = startscale.lerp(inSelectionScale, t)
				t += delta/float(moveTime)
			else:
				t = 0
				position = inSelectionPosition
				rotation = inSelectionRotation
				scale = inSelectionScale
				out_of_place = false
				currentPositionSet = false
			


func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if mousedOver and inReward:
			if event.pressed:
				rewardSelected.emit(self)
				moveToDeck()
		elif mousedOver and inRemove:
			if event.pressed:
				removeSelected.emit(self)
		elif mousedOver and inShop:
			if event.pressed:
				var canAfford = Stats.coinCount >= price
				if canAfford:
					bought.emit(self)
					moveToDeck()
		elif mousedOver and inRemove:
			if event.pressed:
				pass
		elif mousedOver and not card_pressed and not current_playspace.endingTurn and not cardPileShowing and not inReward:
			if event.pressed:
				if current_playspace.selectingCards:
					card_pressed = true
					current_playspace.cardSelected(index, focuspos + size/2, self)
				elif Stats.currentEnergy >= CardInfo[Global.CARD_FIELDS.EnergyCost]:
					card_pressed = true
					# Alert the playspace about which card has been clicked
					current_playspace.cardPressed(index, focuspos + size/2, self)

