extends Node2D

var graph:DirectedGraph

const BASIC_AREAS = ["Corridor", "Diverging", "LostTrack", "SlugForest"]
const MINIBOSSES = ["Moon Witch"]

func _ready():
	graph = DirectedGraph.new()
	
	var uniqueIdCounter = 0
	
	graph.add_node(getBasicMap(), uniqueIdCounter)
	
	uniqueIdCounter += 1
	
	for layer in range(9):
		pass
	

func getBasicMap():
	var mapName = BASIC_AREAS.pick_random()
	return Tile.getMapInfo(mapName)
	

# Returns an array of arrays.  The first value in the sub-arrays tells if there's any special info to render, the second is rewards to add
func getRewardArray(mapName, mirrored=false):
	var numExits = Tile.getNumExits(mapName)
	var cell_info = Tile.mapDb[mapName][Tile.CellInfo]
	var rewardsArray = []
	for i in range(numExits):
		var rewards = []
		var rewardType = cell_info[i][Tile.Rewards]
		
		if rewardType == Tile.REWARDS.Hard:
			if randi_range(0,1) == 1:
				rewards.append([null, TrainCar.getRandomCar()])
			else:
				rewards.append([null, "MoneyBag"])
		
		elif rewardType == Tile.REWARDS.WaterCheck:
			rewards.append(["WaterCheck", TrainCar.getRandomRare()])
		
		rewardsArray.append(rewards)
	
	if mirrored:
		rewardsArray.reverse()
	
	return rewardsArray

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
