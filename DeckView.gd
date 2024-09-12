class_name DeckView extends Node2D

var scene
var cardNames:Array
var numToSelect:int
var confirmButton

signal backButtonPressed
signal confirmPressed(cardList)

func _init(cardNames, numToSelect=0):
	var _scene:PackedScene = load("res://DeckView.tscn")
	scene = _scene.instantiate()
	self.cardNames = cardNames
	self.numToSelect = numToSelect

func _ready():
	add_child(scene)
	var hBoxContainer = scene.get_node("MarginContainer/HBoxContainer")
	var cardContainer = hBoxContainer.get_node("ScrollContainer/CardContainer")
	var backButton = hBoxContainer.get_node("BackVBox/MarginContainer/BackButton")
	confirmButton = hBoxContainer.get_node("ConfirmVBox/MarginContainer/ConfirmButton")
	
	confirmButton.self_modulate.a = 0
	
	if numToSelect > 0:
		confirmButton.pressed.connect(func():
			if confirmButton.self_modulate.a == 0:
				return
			var selectedCardNames = []
			for card in selectedCards:
				selectedCardNames.append(card.CardName)
			
			confirmPressed.emit(selectedCardNames)
				)
	
	backButton.pressed.connect(func(): backButtonPressed.emit())
	
	cardNames.sort_custom(
		func(cardName1, cardName2) :
			var rarity1 = Global.CardDb.DATA[cardName1][Global.CARD_FIELDS.Rarity]
			var rarity2 = Global.CardDb.DATA[cardName2][Global.CARD_FIELDS.Rarity]
			
			if rarity1 == rarity2:
				return cardName1 < cardName2
			
			var card1Val:int
			var card2Val:int 
			
			match rarity1:
				"Starter": card1Val = 0
				"Common": card1Val = 1
				"Uncommon": card1Val = 2
				"Rare": card1Val = 3
				
			match rarity2:
				"Starter": card2Val = 0
				"Common": card2Val = 1
				"Uncommon": card2Val = 2
				"Rare": card2Val = 3
			
			return card1Val < card2Val
	)
	
	for cardName in cardNames:
		var card = Global.CardBase.instantiate()
		card.CardName = cardName
		card.removeSelected.connect(cardClicked)
		if not (numToSelect > 0):
			card.cardPileShowing = true
		else:
			card.inRemove = true
		cardContainer.add_child(card)
		card.state = Global.CARD_STATES.InOverlay
		card.fadeIn()
		card.custom_minimum_size = Vector2(500,700)

var selectedCards = []

func cardClicked(card:CardBase):
	if card in selectedCards:
		selectedCards.remove_at(selectedCards.find(card))
		var cardSelectionBackground = card.get_node("HighlightBorder/SelectionHighlight")
		cardSelectionBackground.visible = false
		if selectedCards.size() == 0:
			confirmButton.self_modulate.a = 0
	else:
		if selectedCards.size() < numToSelect:
			selectedCards.append(card)
			var cardSelectionBackground = card.get_node("HighlightBorder/SelectionHighlight")
			cardSelectionBackground.visible = true
			if selectedCards.size() > 0:
				confirmButton.self_modulate.a = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
