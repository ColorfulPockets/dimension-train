extends Node2D

const CardBase = preload("res://Cards/CardBase.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.instantiateCardLists()
	
	var cards_offered = []
	cards_offered.append(Global.chooseCommon())
	var common2 = Global.chooseCommon()
	while common2 in cards_offered:
		common2 = Global.chooseCommon()
	cards_offered.append(common2)
	
	cards_offered.append(Global.chooseUncommon())
	var uncommon2 = Global.chooseUncommon()
	while uncommon2 in cards_offered:
		uncommon2 = Global.chooseUncommon()
	cards_offered.append(uncommon2)
	
	cards_offered.append(Global.chooseRare())

	
	for i in range(cards_offered.size()):
		var cardName = cards_offered[i]
		var price:Label = get_node(NodePath("./FullScreenContainer/VBoxContainer/CardRow/CardBox" + str(i+1) + "/PriceBox/Price"))
		var card = instantiateCard(cardName)
		var marginContainer:MarginContainer = get_node(NodePath("FullScreenContainer/VBoxContainer/CardRow/CardBox" + str(i+1) + "/BackgroundColor/MarginContainer"))
		var cardPlaceholder = get_node(NodePath("FullScreenContainer/VBoxContainer/CardRow/CardBox" + str(i+1) + "/BackgroundColor/MarginContainer/CardPlaceholder"))
		card.reparent(cardPlaceholder)
		card.position += card.size
		#marginContainer.remove_child(cardPlaceholder)
		
		if cardName in Global.rares:
			price.text = str(Global.RARE_PRICE)
		elif cardName in Global.uncommons:
			price.text = str(Global.UNCOMMON_PRICE)
		else:
			price.text = str(Global.COMMON_PRICE)

func instantiateCard(name):
	var card_shown = CardBase.instantiate()
	card_shown.CardName = name
	card_shown.bought.connect(func(card): cardBought(card))
	add_child(card_shown)
	card_shown.state = Global.CARD_STATES.InOverlay
	card_shown.scale *= 2
	card_shown.inShop = true
	card_shown.fadeIn()
	return card_shown

func cardBought(card:CardBase):
	Stats.coinCount -= card.price

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
