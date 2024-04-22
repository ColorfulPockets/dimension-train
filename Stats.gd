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

var collectRadius = 1

var startingDeckNames = ["Factory","Manufacture", "Mine", "Mine", "Chop", "Chop", "Gather", "Build", "Build", "Gather"]
var deck = []
var rareChance = 0.1

var speedProgression = [0, 1, 2, 2, 2, 1, 1, 1, 1, 1, 1]

func _ready():
	for cardName in startingDeckNames:
		var new_card = CardBase.instantiate()
		new_card.CardName = cardName
		deck.append(new_card)
		
