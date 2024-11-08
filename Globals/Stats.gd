extends Node

const CardBase = preload("res://Cards/CardBase.tscn")

var confirmCardClicks = true

var levelCounter = 0

var woodCount = 0
var starterWoodCount = 5 if not Global.devmode else 100
var metalCount = 0
var starterMetalCount = 5 if not Global.devmode else 100
var emergencyRailCount = 20 if not Global.devmode else 1000
var erc = 20 if not Global.devmode else 1000
var coinCount = 3
var startingTrainSpeed = 100 if Global.devmode else 0
var turnCounter = 0
var trainSpeed = 0
var speedRampFunction = func(x): return x
# Array of speed adjustments for upcoming turns.
var speedAdjustments = []

signal camera_controlled(controlled:bool)
func setCameraStationary():
	camera_controlled.emit(false)

func setCameraControlled():
	camera_controlled.emit(true)

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

func removeWood(num:int):
	if woodCount - num < 0:
		woodCount = 0
	else:
		woodCount -= num
		
var currentEnergy = 3
var maxEnergy = 3

var pickupRange = 1
var startingPickupRange = 1

var startingDeckNames = ["Blast", "Blast", "Harvest", "Harvest", "Harvest", "Gather", "Gather", "Build", "Build"] + ["Hyperbeam"]
var deck = []
var rareChance = 0.1

var dimensionWheelSegments = []

var powersInPlay = []
var debuffs:Dictionary = {}

var current_playspace:Playspace

func set_playspace(playspace):
	current_playspace = playspace
	
var trainCars = ["Chicane Car"]

func startLevel():
	turnCounter = 0
	woodCount = starterWoodCount
	metalCount = starterMetalCount
	currentEnergy = maxEnergy
	powersInPlay = []
	pickupRange = startingPickupRange

func progressTurn():
	turnCounter += 1
	var adjustment = 0
	if speedAdjustments.size() > 0:
		adjustment = speedAdjustments.pop_front()
	trainSpeed = speedRampFunction.call(turnCounter) + adjustment
	
# n is number of turns in the future
func getSpeedForTurn(n:int) -> int:
	if n == 0:
		return trainSpeed
	if speedAdjustments.size() >= n:
		return speedRampFunction.call(turnCounter + n) + speedAdjustments[n-1]
	else:
		return speedRampFunction.call(turnCounter + n)

func _ready():
	for cardName in startingDeckNames:
		deck.append(cardName)
		
