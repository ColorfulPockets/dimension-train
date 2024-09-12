extends Node

var currentScene = null
var previousScene = null
var loaderThread = Thread.new()
var mapName
var currentLocation = Vector2i(0,0)
const LOAD_TIME = 0.25

##########
# Scenes #
##########
var shopScene = preload("res://Card Reward/shop.tscn")
var rewardsScene = preload("res://Card Reward/card_reward.tscn")
var mapScene = preload("res://Playspace/Playspace.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	Stats.setCameraStationary()
	$Background/Swirl.emitting = true
	currentScene = mapScene.instantiate()
	goToNextMap()
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

func goToRewards():
	if "Card" not in Global.selectedReward:
		card_selected()
		return
		
	var rewards = rewardsScene.instantiate()
	rewards.card_selected.connect(card_selected)
	
	previousScene = currentScene
	currentScene = rewards
	
	switchScenes(true)

func getNextMap():
	return ["Corridor", "LostTrack", "SlugForest", "Diverging"].pick_random()

func card_selected():
	if "Shop" in Global.selectedReward:
		var shop = shopScene.instantiate()
		shop.continuePressed.connect(goToNextMap)
		
		previousScene = currentScene
		currentScene = shop
		
		switchScenes(true)
	else:
		goToNextMap()
	
func goToNextMap():
	self.mapName = getNextMap()
	var map = mapScene.instantiate()
	
	map.setMap(mapName)
	
	previousScene = currentScene
	currentScene = map
	map.levelComplete.connect(goToRewards)
	
	switchScenes(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
