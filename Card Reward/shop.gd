extends Control

const FADE_TIME = 0.15

var cards_offered = []
var cars_offered = []

var removeButtonContainer

signal continuePressed

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.instantiateCardLists()
	
	$FullScreenContainer/VBoxContainer/Continue/MarginContainer/ContinueButton.pressed.connect(func():continuePressed.emit())
	
	##########################
	# Connect Remove Button  #
	##########################
	removeButtonContainer = $FullScreenContainer/VBoxContainer/CardRemove
	$FullScreenContainer/VBoxContainer/CardRemove/BackgroundColor/MarginContainer/RemoveButton.pressed.connect(removeClicked)
	$FullScreenContainer/VBoxContainer/CardRemove/PriceBox/Price.text = str(Global.REMOVE_PRICE)
	
	##################
	# Generate Cards #
	##################
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
		var marginContainer = get_node(NodePath("FullScreenContainer/VBoxContainer/CardRow/CardBox" + str(i+1) + "/BackgroundColor/MarginContainer"))
		var card = instantiateCard(cardName, marginContainer)
		card.position += card.size
		
		if cardName in Global.rares:
			price.text = str(Global.RARE_PRICE)
		elif cardName in Global.uncommons:
			price.text = str(Global.UNCOMMON_PRICE)
		else:
			price.text = str(Global.COMMON_PRICE)
	
	generateTrains()
	
	recolorPrices()

func generateTrains():
	###################
	# Generate Trains #
	###################
	TrainCar.populateLists()
	
	var commonCarName = TrainCar.commons.pick_random()
	var uncommonCarName = TrainCar.uncommons.pick_random()
	var rareCarName = TrainCar.rares.pick_random()
	
	cars_offered.append(commonCarName)
	cars_offered.append(uncommonCarName)
	cars_offered.append(rareCarName)
	
	
	var commonCar = TrainCar.new(commonCarName)
	var uncommonCar = TrainCar.new(uncommonCarName)
	var rareCar = TrainCar.new(rareCarName)
	
	commonCar.clicked.connect(func(): carClicked(commonCar))
	uncommonCar.clicked.connect(func(): carClicked(uncommonCar))
	rareCar.clicked.connect(func(): carClicked(rareCar))
	
	var commonPlaceholder = $FullScreenContainer/VBoxContainer/TrainRow/TrainBox1/BackgroundColor/MarginContainer/TrainPlaceholder
	var uncommonPlaceholder = $FullScreenContainer/VBoxContainer/TrainRow/TrainBox2/BackgroundColor/MarginContainer/TrainPlaceholder
	var rarePlaceholder = $FullScreenContainer/VBoxContainer/TrainRow/TrainBox3/BackgroundColor/MarginContainer/TrainPlaceholder
	
	$FullScreenContainer/VBoxContainer/TrainRow/TrainBox1/PriceBox/Price.text = str(Global.COMMON_CAR_PRICE)
	$FullScreenContainer/VBoxContainer/TrainRow/TrainBox2/PriceBox/Price.text = str(Global.UNCOMMON_CAR_PRICE)
	$FullScreenContainer/VBoxContainer/TrainRow/TrainBox3/PriceBox/Price.text = str(Global.RARE_CAR_PRICE)
	
	commonCar.scale *= commonPlaceholder.size / commonCar.textureRect.texture.get_size()
	commonCar.position = commonPlaceholder.size / 2
	
	uncommonCar.scale *= uncommonPlaceholder.size / uncommonCar.textureRect.texture.get_size()
	uncommonCar.position = uncommonPlaceholder.size / 2
	
	rareCar.scale *= rarePlaceholder.size / rareCar.textureRect.texture.get_size()
	rareCar.position = rarePlaceholder.size / 2
	
	commonPlaceholder.add_child(commonCar)
	uncommonPlaceholder.add_child(uncommonCar)
	rarePlaceholder.add_child(rareCar)

func recolorPrices():
	var cardBoxes = $FullScreenContainer/VBoxContainer/CardRow.get_children()
	var trainBoxes = $FullScreenContainer/VBoxContainer/TrainRow.get_children()
	var cardRemoveBox = $FullScreenContainer/VBoxContainer/CardRemove
	
	var allPriceBoxes = cardBoxes + trainBoxes
	allPriceBoxes.append(cardRemoveBox)
	
	for priceBox in allPriceBoxes:
		var price:int = priceBox.get_node("PriceBox/Price").text.to_int()
		if price > Stats.coinCount:
			priceBox.get_node("PriceBox/Price").self_modulate = Color(1,0,0)
		else:
			priceBox.get_node("PriceBox/Price").self_modulate = Color(1,1,1)

var alreadyRemoved = false
func removeClicked():
	if Stats.coinCount < Global.REMOVE_PRICE:
		return
	if alreadyRemoved:
		return
	
	var removeView = DeckView.new(Stats.deck, 1)
	add_child(removeView)
	removeView.backButtonPressed.connect(func(): removeView.queue_free())
	removeView.confirmPressed.connect(func(cardSelected):
		Stats.deck.remove_at(Stats.deck.find(cardSelected[0]))
		Stats.coinCount -= Global.REMOVE_PRICE
		removeView.queue_free()
		removeButtonContainer.get_node("BackgroundColor/MarginContainer/RemoveButton").queue_free()
		removeButtonContainer.get_node("PriceBox").modulate.a = 0
		recolorPrices()
		)

func instantiateCard(name, parent):
	var card_shown = Global.CardBase.instantiate()
	card_shown.CardName = name
	card_shown.bought.connect(func(card): cardBought(card))
	parent.add_child(card_shown)
	card_shown.state = Global.CARD_STATES.InOverlay 
	card_shown.inShop = true
	card_shown.fadeIn()
	return card_shown

func cardBought(card:CardBase):
	Stats.coinCount -= card.price
	Stats.deck.append(card.CardName)
	var cardName = card.CardName
	
	var i = cards_offered.find(cardName)
	
	var price:Label = get_node(NodePath("./FullScreenContainer/VBoxContainer/CardRow/CardBox" + str(i+1) + "/PriceBox/Price"))
	var coin:TextureRect = get_node(NodePath("./FullScreenContainer/VBoxContainer/CardRow/CardBox" + str(i+1) + "/PriceBox/CoinIcon"))
	var cardPlaceholder = get_node(NodePath("FullScreenContainer/VBoxContainer/CardRow/CardBox" + str(i+1) + "/BackgroundColor/MarginContainer/CardPlaceholder"))
	
	card.reparent(self, true)
	
	Global.fadeOutNode(price, FADE_TIME)
	Global.fadeOutNode(coin, FADE_TIME)
	recolorPrices()

func getCarPrice(car:TrainCar):
	match car.rarity:
		TrainCar.RARITY.COMMON:
			return Global.COMMON_CAR_PRICE
		TrainCar.RARITY.UNCOMMON:
			return Global.UNCOMMON_CAR_PRICE
		TrainCar.RARITY.RARE:
			return Global.RARE_CAR_PRICE

func carClicked(car:TrainCar):
	if car.buyable == false:
		return
	if Stats.coinCount < getCarPrice(car):
		return
	
	car.buyable = false
	Stats.coinCount -= getCarPrice(car)
	Stats.trainCars.append(car.carName)
	var carName = car.carName
	
	var i = cars_offered.find(carName)
	
	var price:Label = get_node(NodePath("./FullScreenContainer/VBoxContainer/TrainRow/TrainBox" + str(i+1) + "/PriceBox/Price"))
	var coin:TextureRect = get_node(NodePath("./FullScreenContainer/VBoxContainer/TrainRow/TrainBox" + str(i+1) + "/PriceBox/CoinIcon"))
	var carPlaceholder = get_node(NodePath("FullScreenContainer/VBoxContainer/TrainRow/TrainBox" + str(i+1) + "/BackgroundColor/MarginContainer/TrainPlaceholder"))
	
	Global.fadeOutNode(price, FADE_TIME)
	Global.fadeOutNode(coin, FADE_TIME)
	recolorPrices()
	await Global.fadeOutNode(car, FADE_TIME)
	
	car.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
