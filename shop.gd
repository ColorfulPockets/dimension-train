extends Control

const CardBase = preload("res://Cards/CardBase.tscn")

const FADE_TIME = 0.15

var cards_offered = []
var cars_offered = []

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.instantiateCardLists()
	
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
		var card = instantiateCard(cardName)
		var cardPlaceholder = get_node(NodePath("FullScreenContainer/VBoxContainer/CardRow/CardBox" + str(i+1) + "/BackgroundColor/MarginContainer/CardPlaceholder"))
		card.reparent(cardPlaceholder)
		card.position += card.size
		
		if cardName in Global.rares:
			price.text = str(Global.RARE_PRICE)
		elif cardName in Global.uncommons:
			price.text = str(Global.UNCOMMON_PRICE)
		else:
			price.text = str(Global.COMMON_PRICE)
	
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
	Stats.deck.append(card.CardName)
	var cardName = card.CardName
	
	var i = cards_offered.find(cardName)
	
	var price:Label = get_node(NodePath("./FullScreenContainer/VBoxContainer/CardRow/CardBox" + str(i+1) + "/PriceBox/Price"))
	var coin:TextureRect = get_node(NodePath("./FullScreenContainer/VBoxContainer/CardRow/CardBox" + str(i+1) + "/PriceBox/CoinIcon"))
	var cardPlaceholder = get_node(NodePath("FullScreenContainer/VBoxContainer/CardRow/CardBox" + str(i+1) + "/BackgroundColor/MarginContainer/CardPlaceholder"))
	
	reparent_and_keep_position_ui(card, self)
	
	Global.fadeOutNode(price, FADE_TIME)
	Global.fadeOutNode(coin, FADE_TIME)

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
	await Global.fadeOutNode(car, FADE_TIME)
	
	car.queue_free()

#GPT
func reparent_and_keep_position_ui(node: Control, new_parent: Control) -> void:
	# Store the global position of the control node
	var old_global_position = node.global_position

	# Remove the node from its current parent and add it to the new parent
	node.get_parent().remove_child(node)
	new_parent.add_child(node)

	# Restore the global position to keep the node in the same position on screen
	node.global_position = old_global_position + node.size/2



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
