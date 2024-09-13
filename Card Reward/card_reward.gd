extends VBoxContainer

@onready var skipTexture = preload("res://Assets/UI/Skip Button.png")
@onready var skipHoverTexture = preload("res://Assets/UI/Skip Hover.png")

signal card_selected

var cardsToOffer = []
# The dimension that Skip will push toward
var skipType = "Water"

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.instantiateCardLists()
	chooseCards()

const HORIZONTAL_SPACING = 50

func chooseCards():
	cardsToOffer = []
	for i in range(3):
		var cardChosen = ""
		if randf_range(0.0,1.0) < Stats.rareChance:
			cardChosen = Global.chooseRare()
			while cardChosen in cardsToOffer:
				cardChosen = Global.chooseRare()
		elif randf_range(0.0,1.0) < 0.3:
			cardChosen = Global.chooseUncommon()
			while cardChosen in cardsToOffer:
				cardChosen = Global.chooseUncommon()
		else:
			cardChosen = Global.chooseCommon()
			while cardChosen in cardsToOffer:
				cardChosen = Global.chooseCommon()
		cardsToOffer.append(cardChosen)
	
	for i in range(3):
		var card_shown = Global.CardBase.instantiate()
		card_shown.CardName = cardsToOffer[i]
		card_shown.rewardSelected.connect(cardSelected, 1)
		var cardMarginContainer = get_node("HBoxContainer/CardRow/CardBox" + str(i+1) + "/MarginContainer")
		cardMarginContainer.add_child(card_shown)
		card_shown.state = Global.CARD_STATES.InOverlay
		card_shown.inReward = true
		card_shown.position = (get_viewport_rect().size / 2 + (i-1)*Vector2(card_shown.size.x*card_shown.scale.x + HORIZONTAL_SPACING,0)) - card_shown.size/2
		card_shown.fadeIn()
		
	# Add Skip button
	var skipButton:TextureButton = TextureButton.new()
	skipButton.texture_normal = skipTexture
	skipButton.texture_hover = skipHoverTexture
	skipButton.scale *= 0.5
	skipButton.position = get_viewport_rect().size / 2 - skipButton.scale*skipButton.texture_normal.get_size()/2 + Vector2(0,600)
	skipButton.pressed.connect(func(): cardSelected(null))
	skipButton.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	
	var skipBox:TextureRect = TextureRect.new()
	var types = ["Water", "Ice", "Fire"]
	types.shuffle()
	skipType = types.pop_front()
	skipBox.texture = load("res://Assets/UI/Dimension Wheel/" + skipType + " Box.png")
	var skipBoxIcon:TextureRect = TextureRect.new()
	skipBoxIcon.texture = load("res://Assets/UI/Dimension Wheel/" + skipType + " Icon.png")
	skipBox.custom_minimum_size = Vector2(256,256)
	skipBox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var centeringBox = HBoxContainer.new()
	centeringBox.alignment = BoxContainer.ALIGNMENT_CENTER
	centeringBox.custom_minimum_size = Vector2(256,256)
	skipBox.add_child(centeringBox)
	skipBoxIcon.custom_minimum_size = Vector2(128,128)
	skipBoxIcon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	skipBoxIcon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(skipBox)
	centeringBox.add_child(skipBoxIcon)
	
	var spacer1 = Control.new()
	spacer1.custom_minimum_size = Vector2(0,30)
	add_child(spacer1)
	
	add_child(skipButton)
	
	var spacer2 = Control.new()
	spacer2.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(spacer2)
	

func cardSelected(card):
	var dimension
	if card != null:
		Stats.deck.append(card.CardName)
		match cardsToOffer.find(card.CardName):
			0:
				dimension = "Water"
			1: 
				dimension = "Fire"
			2:
				dimension = "Ice"
		
	else:
		dimension = skipType
	
	Stats.dimensionWheelSegments.append(dimension)
	if Stats.dimensionWheelSegments.size() > 8:
		Stats.dimensionWheelSegments.pop_front()
	$"../EverywhereUI/Dimension Wheel".resetWheel()
	card_selected.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
