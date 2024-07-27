extends Node

const CardBase = preload("res://Cards/CardBase.tscn")

var confirmCardClicks = true

var levelCounter = 0

var woodCount = 0
var starterWoodCount = 0
var metalCount = 0
var starterMetalCount = 0
var emergencyRailCount = 20
var erc = 20

func addEmergencyRail(num:int): 
	if emergencyRailCount + num <= erc:
		emergencyRailCount += num
	else:
		emergencyRailCount = erc

func removeEmergencyRail(num:int):
	if emergencyRailCount - num < 0:
		emergencyRailCount = 0
	else:
		emergencyRailCount -= num

var railCount = 0
var starterRail = 7
var coinCount = 0

var startingTrainSpeed = 0
var turnCounter = 0
var trainSpeed = 0
func resetTrainSpeed():
	trainSpeed = startingTrainSpeed + turnCounter

var currentEnergy = 3
var maxEnergy = 3

var collectRadius = 1
var startingCollectRadius = 1

var startingDeckNames = ["Brake", "Magnet", "Bridge","Factory","Manufacture", "Mine", "Mine", "Chop", "Chop", "Gather", "Build", "Build", "Gather"]
var deck = []
var rareChance = 0.1

var powersInPlay = []

var current_playspace

func set_playspace(playspace):
	current_playspace = playspace
	
var trainCars = ["Cargo Car", "Brake Car", "Magnet Car"]

func startLevel():
	turnCounter = 0
	railCount =  starterRail
	woodCount = starterWoodCount
	metalCount = starterMetalCount
	currentEnergy = maxEnergy
	powersInPlay = []
	collectRadius = startingCollectRadius
	

func _ready():
	for cardName in startingDeckNames:
		deck.append(cardName)
		
