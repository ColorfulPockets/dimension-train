extends Node

const CardBase = preload("res://Cards/CardBase.tscn")

var woodCount = 0
var metalCount = 0
var emergencyRailCount = 20
var erc = 20

func addEmergencyRail(num:int): 
	if emergencyRailCount + num <= erc:
		emergencyRailCount += num
	else:
		emergencyRailCount = erc

var railCount = 0
var starterRail = 100
var coinCount = 0

var trainSpeed = 0
var nextTrainSpeed = 1
var turnCounter = 0

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
	
var trainCars = ["Brake Car", "Brake Car"]

func _ready():
	for cardName in startingDeckNames:
		deck.append(cardName)
		
