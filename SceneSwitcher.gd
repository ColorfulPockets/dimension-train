extends Node

var currentScene = null
var previousScene = null
var loaderThread = Thread.new()
var currentLocation = Vector2i(0,0)
const LOAD_TIME = 0.25
const MAP_FADE_TIME = 0.25

@onready var overworld:Overworld

##########
# Scenes #
##########
var shopScene = preload("res://Card Reward/shop.tscn")
var railyardScene = preload("res://rail_yard.tscn")
var rewardsScene = preload("res://Card Reward/card_reward.tscn")
var mapScene = preload("res://Playspace/Playspace.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	Stats.setCameraStationary()
	$Background/Swirl.emitting = true
	overworld = $EverywhereUI/Overworld
	overworld.train_finished_moving.connect(trainFinishedMoving)
	currentScene = mapScene.instantiate()
	goToNextNode(0)
	#$EverywhereUI/AudioStreamPlayer.play()

func switchScenes(setCameraStationary:bool = false):
	await Global.fadeOutNode(previousScene, LOAD_TIME)
	if setCameraStationary:
		Stats.setCameraStationary()
	else:
		Stats.setCameraControlled()
	currentScene.modulate.a = 0
	add_child(currentScene)	
	Global.fadeInNode(currentScene, LOAD_TIME)
	previousScene.queue_free()

func goToNextNode(pathIndex:int):
	overworld.visible = true
	overworld.modulate.a = 0
	$"EverywhereUI/Top Bar/TopBar HBox".ignorePresses = true
	await Global.fadeInNode(overworld, MAP_FADE_TIME)
	
	overworld.advanceTrain(pathIndex)
	
	var nodeName = overworld.currentNode.mapName
	
	if nodeName == "Shop":
		goToShop()
	elif nodeName == "Railyard":
		goToRailyard()
	else:
		goToMap()
		
func trainFinishedMoving():
	await Global.fadeOutNode(overworld, MAP_FADE_TIME)
	overworld.modulate.a = 1
	overworld.visible = false
	$"EverywhereUI/Top Bar/TopBar HBox".ignorePresses = false

func goToMap():
	var map = mapScene.instantiate()
	
	previousScene = currentScene
	currentScene = map
	map.levelComplete.connect(func(x): goToRewards(x))
	
	switchScenes(false)

func goToRewards(pathIndex:int):
	var rewards = rewardsScene.instantiate()
	rewards.card_selected.connect(func(): 
		Stats.coinCount += randi_range(0,2)
		goToNextNode(pathIndex))
	
	previousScene = currentScene
	currentScene = rewards
	
	switchScenes(true)

func goToShop():
	var shop = shopScene.instantiate()
	shop.continuePressed.connect(func(): goToNextNode(0))
	
	previousScene = currentScene
	currentScene = shop
	
	switchScenes(true)

func goToRailyard():
	var railyard = railyardScene.instantiate()
	railyard.choice_made.connect(func(): goToNextNode(0))
	
	previousScene = currentScene
	currentScene = railyard
	
	switchScenes(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
