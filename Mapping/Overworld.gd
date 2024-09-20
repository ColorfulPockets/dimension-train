class_name Overworld extends PanelContainer

static var graph:DirectedGraph

const BASIC_AREAS = ["Corridor", "Diverging", "LostTrack", "SlugForest"]
const MINIBOSSES = ["Moon Witch"]

func _ready():
	graph = DirectedGraph.new()
	
	var root = getBasicMap()
	graph.add_node(root)
	
	var prevLayerIndex = 0
	var currentLayerIndex = 1
	var layers = [[root], []]
	for layer in range(9):
		var prevLayer = layers[prevLayerIndex]
		var currentLayer = layers[currentLayerIndex]
		for prevNode in prevLayer:
			if currentLayer.size() == 0:
				for reward in prevNode.rewardsArray:
					var nextNode = getNextNode(prevNode)
					currentLayer.append(nextNode)
					graph.add_node(nextNode, [prevNode])
			else:
				for i in range(prevNode.rewardsArray.size()):
					if i == 0:
						var connectionNode = currentLayer[-1]
						var connectionValid = true
						if prevNode.mapName in BASIC_AREAS:
							connectionValid = true
						elif prevNode.mapName in MINIBOSSES and connectionNode.mapName in MINIBOSSES:
							connectionValid = false
						elif prevNode.mapName == connectionNode.mapName:
							connectionValid = false
						
						if connectionValid:
							graph.add_connection(prevNode, connectionNode)
						else:
							var nextNode = getNextNode(prevNode)
							currentLayer.append(nextNode)
							graph.add_node(nextNode, [prevNode])
					else:
						var nextNode = getNextNode(prevNode)
						currentLayer.append(nextNode)
						graph.add_node(nextNode, [prevNode])
		prevLayerIndex += 1
		currentLayerIndex += 1
		layers.append([])
	
	$ScrollContainer/VBoxContainer/MarginContainer/HBoxContainer.drawMap(layers)
			

func getNextNode(prevNode:MapRewards) -> MapRewards:
	var retry = true
	var newMap = getBasicMap()
	while retry:
		retry = false
		newMap = getBasicMap()
		match randi_range(0,5):
			0: 
				newMap = MapRewards.new("Shop", null, [[]])
			1: 
				if prevNode.mapName in MINIBOSSES:
					retry = true
				else:
					newMap = getMiniBoss()
			2:
				newMap = MapRewards.new("Rail Yard", null, [[]])
		if newMap.mapName == prevNode.mapName:
			retry = true
			
	return newMap
	
func getMiniBoss() -> MapRewards:
	var mapName = MINIBOSSES.pick_random()
	return  getMapWithRewards(mapName)

func getBasicMap() -> MapRewards:
	var mapName = BASIC_AREAS.pick_random()
	return  getMapWithRewards(mapName)
	
# Returns: [mapName, isMirrored:bool, cells, cell_info, rewardArray]
func getMapWithRewards(mapName) -> MapRewards:
	var mapInfo = Tile.getMapInfo(mapName)
	mapInfo.append(getRewardArray(mapName, mapInfo[1]))
	
	var mapRewards:MapRewards = MapRewards.new(mapInfo[0], mapInfo[1], mapInfo[4])
	return mapRewards

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
