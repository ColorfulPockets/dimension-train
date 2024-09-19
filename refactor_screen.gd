extends MarginContainer

var chosenRefactor = []
signal refactor_chosen(chosenRefactor)

func populateCards(cardsToRefactor):
	for i in range(cardsToRefactor.size()):
		var marginContainer = get_node("VBoxContainer/HBoxContainer/RefactorCards/CardBox" + str(i+1) + "/BackgroundColor/MarginContainer")
		var card = instantiateCard(cardsToRefactor[i], marginContainer)
		var rarity = Global.CardDb.DATA[cardsToRefactor[i]][Global.CARD_FIELDS.Rarity]
		for j in range(1,4):
			var cardOptionContainer = get_node("VBoxContainer/HBoxContainer/OptionsContainer/Option" + str(j) + "/MarginContainer/Cards/CardBox" + str(i+1) + "/BackgroundColor/MarginContainer")
			var optionCardName = Global.chooseForRarity(rarity)
			instantiateCard(optionCardName, cardOptionContainer)

func instantiateCard(name, parent):
	var card_shown = Global.CardBase.instantiate()
	card_shown.CardName = name
	parent.add_child(card_shown)
	card_shown.state = Global.CARD_STATES.InOverlay 
	#card_shown.inShop = true
	#card_shown.fadeIn()
	return card_shown

func optionSelected(selectedOptionPanelNode):
	chosenRefactor = []
	for i in range(1,4):
		var optionPanelNode = get_node("VBoxContainer/HBoxContainer/OptionsContainer/Option" + str(i) + "/Panel")
		if optionPanelNode != selectedOptionPanelNode:
			optionPanelNode.deselect()
		else:
			for j in range(1,4):
				var cardName = get_node("VBoxContainer/HBoxContainer/OptionsContainer/Option" + str(i) + "/MarginContainer/Cards/CardBox" + str(j) + "/BackgroundColor/MarginContainer").get_child(0).CardName
				chosenRefactor.append(cardName)
	$VBoxContainer/HBoxContainer/AspectRatioContainer/Button.self_modulate.a = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/HBoxContainer/AspectRatioContainer/Button.self_modulate.a = 0
	$VBoxContainer/HBoxContainer/AspectRatioContainer/Button.pressed.connect(func():
		refactor_chosen.emit(chosenRefactor))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
