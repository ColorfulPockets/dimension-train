extends Node

const CardBase = preload("res://Cards/CardBase.tscn")

var woodCount = 0
var metalCount = 0
var emergencyRailCount = 20
var erc = 20
var railCount = 100

var trainSpeed = 0
var nextTrainSpeed = 1

var currentEnergy = 3
var maxEnergy = 3

var collectRadius = 1

var startingDeckNames = ["Factory","Manufacture", "Mine", "Mine", "Chop", "Chop", "Gather", "Build", "Build", "Gather"]
var deck = []
var rareChance = 0.1

var speedProgression = [0, 5, 5]

var current_playspace

func set_playspace(playspace):
	current_playspace = playspace

func _ready():
	for cardName in startingDeckNames:
		deck.append(cardName)
		
