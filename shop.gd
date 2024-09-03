extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.instantiateCardLists()
	

func instantiateCard(name):
	var card_shown = CardBase.new()
	card_shown.CardName = name
	card_shown.bought.connect(func(card): cardBought(card))
	add_child(card_shown)
	card_shown.state = Global.CARD_STATES.InOverlay
	card_shown.scale = Global.CARD_SIZE
	card_shown.inShop = true
	card_shown.fadeIn()
	return card_shown

func cardBought(card:CardBase):
	Stats.coinCount -= card.price

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
