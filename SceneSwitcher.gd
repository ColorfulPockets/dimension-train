extends Node

@onready var currentScene = $Overworld
var previousScene = null
var loaderThread = Thread.new()
var mapName
var currentLocation = Vector2i(0,0)
const LOAD_TIME = 0.25

# Called when the node enters the scene tree for the first time.
func _ready():
	Stats.setCameraStationary()
	$Background/Swirl.emitting = true
	currentScene.map_selected.connect(mapSelected,2)
	currentScene.drawMap(currentLocation)
	#$EverywhereUI/AudioStreamPlayer.play()

func loadMapBackground():
	var map = load("res://Playspace/Playspace.tscn").instantiate()
	
	call_deferred("fadeInMap")
	
	return map

func fadeInMap():
	var map = loaderThread.wait_to_finish()
	add_child(map)
	map.setMap(mapName)
	
	Global.fadeInNode(map, LOAD_TIME)
	
	currentScene = map
	Stats.setCameraControlled()
	currentScene.levelComplete.connect(moveToRewards)
	
func moveToRewards():
	if "Card" not in Global.selectedReward:
		card_selected()
		return
	loaderThread.start(loadRewardsBackground)
	previousScene = currentScene
	await Global.fadeOutNode(previousScene, LOAD_TIME)
	previousScene.queue_free()

func loadRewardsBackground():
	var rewards = load("res://Card Reward/card_reward.tscn").instantiate()
	
	call_deferred("fadeInRewards")
	
	return rewards
	
func fadeInRewards():
	var rewards = loaderThread.wait_to_finish()
	
	Stats.setCameraStationary()
	currentScene = rewards
	
	currentScene.card_selected.connect(card_selected)
	
	add_child(currentScene)
	
	Global.fadeInNode(rewards, LOAD_TIME)

func getNextMap():
	return ["Corridor", "LostTrack", "SlugForest", "Diverging"].pick_random()

func card_selected():
	self.mapName = getNextMap()
	
	previousScene = currentScene
	
	loaderThread.start(loadMapBackground)
	
	await Global.fadeOutNode(previousScene, LOAD_TIME)
	
	previousScene.queue_free()

func mapSelected(mapName, newLocation:Vector2i):
	self.mapName = mapName
	self.currentLocation = newLocation
	loaderThread.start(loadMapBackground)
	
	previousScene = currentScene
	
	await Global.fadeOutNode(previousScene, LOAD_TIME)
		
	previousScene.queue_free()

func fadeInOverworld():
	var overworld = loaderThread.wait_to_finish()
	
	Stats.setCameraStationary()
	currentScene = overworld
	
	currentScene.map_selected.connect(mapSelected,1)
	
	add_child(overworld)
	
	currentScene.drawMap(currentLocation)
	
	Global.fadeInNode(overworld, LOAD_TIME)
	
	
func loadOverworldBackground():
	var overworld = load("res://overworld.tscn").instantiate()
	
	call_deferred("fadeInOverworld")
	
	return overworld

func returnToOverworld():
	loaderThread.start(loadOverworldBackground)
	
	previousScene = currentScene
	
	await Global.fadeOutNode(previousScene, LOAD_TIME)
	
	previousScene.queue_free()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
