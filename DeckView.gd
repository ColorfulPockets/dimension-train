class_name DeckView extends Node2D

var scene
var cardNames

func _init(cardNames):
	var _scene:PackedScene = load("res://DeckView.tscn")
	scene = _scene.instantiate()
	self.cardNames = cardNames

func _ready():
	add_child(scene)
	var cardContainer = scene.get_child(0).get_child(0).get_child(0)
	
	for cardName in cardNames:
		var card = Global.CardBase.instantiate()
		card.CardName = cardName
		card.inRemove = true
		cardContainer.add_child(card)
		card.state = Global.CARD_STATES.InOverlay
		card.fadeIn()
		card.custom_minimum_size = Vector2(500,700)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
