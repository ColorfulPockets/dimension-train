class_name Overworld extends PanelContainer

var TRAIN_MOVE_TIME = 1.0

static var graph:DirectedGraph

const BASIC_AREAS = ["Corridor", "Diverging", "LostTrack", "SlugForest"]
const MINIBOSSES = ["Moon Witch"]

var currentNode: MapRewards
var trainAvatar:TrainCar

func _ready():
	graph = DirectedGraph.new()
	
	var preRoot = MapRewards.new("Empty", false, [])
	
	var root = getBasicMap()
	graph.add_node(preRoot)
	graph.add_node(root, [[preRoot, [0]]])
	currentNode = preRoot
	
	var prevLayerIndex = 1
	var currentLayerIndex = 2
	var layers = [[preRoot],[root], []]
	for layer in range(1,10):
		var prevLayer = layers[prevLayerIndex]
		var currentLayer = layers[currentLayerIndex]
		for prevNode in prevLayer:
			if currentLayer.size() == 0:
				for reward in prevNode.rewardsArray:
					var nextNode = getNextNode(prevNode, currentLayerIndex)
					currentLayer.append(nextNode)
					graph.add_node(nextNode, [[prevNode, reward]])
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
							graph.add_connection(prevNode, connectionNode, prevNode.rewardsArray[i])
						else:
							var nextNode = getNextNode(prevNode, currentLayerIndex)
							currentLayer.append(nextNode)
							graph.add_node(nextNode, [[prevNode, prevNode.rewardsArray[i]]])
					else:
						var nextNode = getNextNode(prevNode, currentLayerIndex)
						currentLayer.append(nextNode)
						graph.add_node(nextNode, [[prevNode, prevNode.rewardsArray[i]]])
		prevLayerIndex += 1
		currentLayerIndex += 1
		layers.append([])
	
	await $ScrollContainer/VBoxContainer/MarginContainer/HBoxContainer.drawMap(layers)
	
	trainAvatar = TrainCar.new("Front")
	trainAvatar.scale *= 4
	$ScrollContainer/VBoxContainer/MarginContainer.add_child(trainAvatar)
	trainAvatar.global_position = currentNode.global_position + trainAvatar.scale*trainAvatar.textureRect.size/2

func getNextNode(prevNode:MapRewards, currentLayerIndex:int) -> MapRewards:
	var retry = true
	var newMap = getBasicMap()
	# First layer is always basic maps to let you spread out for more options
	if currentLayerIndex == 1:
		return newMap
	while retry:
		retry = false
		newMap = getBasicMap()
		match randi_range(0,5):
			0: 
				newMap = MapRewards.new("Shop", false, [[0]])
			1: 
				if prevNode.mapName in MINIBOSSES:
					retry = true
				else:
					newMap = getMiniBoss()
			2:
				newMap = MapRewards.new("Railyard", false, [[0]])
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
	var mapInfo = [mapName]
	if randi_range(0,1) == 1:
		mapInfo.push_back(true)
	else:
		mapInfo.push_back(false)
	mapInfo.push_back(getRewardArray(mapName, mapInfo[1]))
	
	var mapRewards:MapRewards = MapRewards.new(mapInfo[0], mapInfo[1], mapInfo[2])
	return mapRewards

# Returns an array of arrays.  
# The first value in the sub-arrays tells if there's any special info to render, 
# the second is rewards to add,
# the third is an index so we can tell which path is taken
func getRewardArray(mapName, mirrored=false):
	var numExits = Tile.getNumExits(mapName)
	var cell_info = Tile.mapDb[mapName][Tile.CellInfo]
	var rewardsArray = []
	for i in range(numExits):
		var rewards = []
		var rewardType = cell_info[i][Tile.Rewards]
		
		if rewardType == Tile.REWARDS.Hard:
			if randi_range(0,2) != 0:
				rewards = [null, TrainCar.getRandomCar()]
			else:
				rewards = [null, "MoneyBag"]
		
		elif rewardType == Tile.REWARDS.WaterCheck:
			rewards = ["WaterCheck", TrainCar.getRandomRare()]
		
		rewardsArray.append(rewards)
	
	if mirrored:
		rewardsArray.reverse()
	
	for i in range(rewardsArray.size()):
		var rewards = rewardsArray[i]
		rewards.push_front(i)
	
	return rewardsArray

func advanceTrain(pathIndex):
	var nextNode
	for connection in graph.get_connections_for_node(currentNode):
		#connection is [node, value], where value is the rewards array
		if connection[1][0] == pathIndex:
			nextNode = connection[0]
	
	await moveTrainBetweenNodes(currentNode, nextNode)

func moveTrainBetweenNodes(currentNode:MapRewards, nextNode:MapRewards):
	var start_point = currentNode.global_position + trainAvatar.scale*trainAvatar.textureRect.size/2
	var end_point = nextNode.global_position + trainAvatar.scale*trainAvatar.textureRect.size/2
	
	# GPT
	var time_passed = 0.0
	
	while time_passed < TRAIN_MOVE_TIME:
		time_passed += get_process_delta_time()
		var t = time_passed / TRAIN_MOVE_TIME # normalized time (0 to 1)
		trainAvatar.global_position = start_point.lerp(end_point, t) # interpolate position
		await get_tree().process_frame # wait for next frame
	
	self.currentNode = nextNode

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
