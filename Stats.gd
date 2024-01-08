extends Node

const CardBase = preload("res://Cards/CardBase.tscn")

var woodCount = 0
var metalCount = 0
var emergencyRailCount = 20
var erc = 20
var railCount = 5

var trainSpeed = 0
var nextTrainSpeed = 1

var currentEnergy = 3
var maxEnergy = 3

var startingDeckNames = ["Factory","Manufacture", "Mine", "Mine", "Mine", "Chop", "Chop", "Chop", "Build", "Build", "Build"]
var deck = []
var rareChance = 0.1

func _ready():
	for cardName in startingDeckNames:
		var new_card = CardBase.instantiate()
		new_card.CardName = cardName
		deck.append(new_card)
		
