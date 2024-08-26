extends Node2D

@onready var CardDb = preload("res://Cards/CardDatabase.gd").new()
@onready var skipTexture = preload("res://Assets/UI/Skip Button.png")
@onready var skipHoverTexture = preload("res://Assets/UI/Skip Hover.png")
const CardBase = preload("res://Cards/CardBase.tscn")
signal card_selected

static var commons = []
static var uncommons = []
static var rares = []
static var cardListsInstantiated = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if not cardListsInstantiated:
		for cardName in CardDb.DATA.keys():
			match CardDb.DATA[cardName][Global.CARD_FIELDS.Rarity]:
				"Common":
					commons.append(cardName)
				"Uncommon":
					uncommons.append(cardName) 
				"Rare":
					rares.append(cardName)
		cardListsInstantiated = true
	chooseCards()

const HORIZONTAL_SPACING = 50

func chooseCards():
	var cardsToOffer = []
	for i in range(3):
		var cardChosen = ""
		if randf_range(0.0,1.0) < Stats.rareChance:
			cardChosen = rares[randi_range(0,rares.size()-1)]
			while cardChosen in cardsToOffer:
				cardChosen = rares[randi_range(0,rares.size()-1)]
		elif randf_range(0.0,1.0) < 0.3:
			cardChosen = uncommons[randi_range(0,uncommons.size()-1)]
			while cardChosen in cardsToOffer:
				cardChosen = uncommons[randi_range(0,uncommons.size()-1)]
		else:
			cardChosen = commons[randi_range(0,commons.size()-1)]
			while cardChosen in cardsToOffer:
				cardChosen = commons[randi_range(0,commons.size()-1)]
		cardsToOffer.append(cardChosen)
	
	for i in range(3):
		var card_shown = CardBase.instantiate()
		card_shown.CardName = cardsToOffer[i]
		card_shown.rewardSelected.connect(cardSelected, 1)
		add_child(card_shown)
		card_shown.state = Global.CARD_STATES.InOverlay
		card_shown.scale *=2
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
	
	add_child(skipButton)
	

func cardSelected(card):
	if card != null:
		Stats.deck.append(card.CardName)
	card_selected.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
