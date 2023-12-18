extends Node2D

signal map_selected(mapName, location)

var map = [
	["Plains"],
	["Mountain", "Plains"],
	["Plains","Plains","Plains",],
	["Plains", "Forest", "Mountain", "Plains"],
	["Plains", "Forest"],
	["Mountain"]
]
var numConnectionsBackward = []
var numConnectionsForward = []
var sprites = []
var verticalDistanceFromCenter = []
var forwardConnections = []

var currentLocation = Vector2i(0,0)

const MARGIN_SIDES = 200
const MARGIN_VERTICAL = 400
const NUM_CONNECTION_DISTRIBUTION = [1,1,1,1,1,1,1,1,2,3]

@onready var mapHeight = (get_viewport().size.y - 2*MARGIN_VERTICAL)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func drawMap(currentLocation):
	self.currentLocation = currentLocation
	var horizontalSpread = (get_viewport().size.x - 2*MARGIN_SIDES) / map.size()
	var largestLayer = 0
	for layer in map:
		if layer.size() > largestLayer:
			largestLayer = layer.size()
	
	var verticalSpread = mapHeight / largestLayer
	
	var viewportCenter = get_viewport_rect().size / 2
	
	for i in range(map.size()):
		var layer = map[i]
		numConnectionsBackward.append([])
		numConnectionsForward.append([])
		verticalDistanceFromCenter.append([])
		forwardConnections.append([])
		sprites.append([])
		for j in range(layer.size()):
			var locationName = layer[j]
			numConnectionsForward[i].append(
				NUM_CONNECTION_DISTRIBUTION[randi_range(0,NUM_CONNECTION_DISTRIBUTION.size() - 1)]
				)
			numConnectionsBackward[i].append(0)
			verticalDistanceFromCenter[i].append(
				proximityToCenter(j, layer)
			)
			forwardConnections[i].append([])
			var iconSprite = MapNode.new()
			iconSprite.texture = load("res://Assets/Icons/" + locationName + ".png")
			iconSprite.position = Vector2(
				viewportCenter.x - horizontalSpread * ((float(map.size()-1)/2 - i) ),
				viewportCenter.y - verticalSpread * ((float(layer.size()-1)/2 - j) )
			)
			
			var maps = ["Corridor"]
			match locationName:
				"Plains":
					maps = ["Corridor"]
				"Mountain":
					pass
				"Forest":
					pass
				_:
					push_error("Error: No map found for " + locationName)
			
			iconSprite.map = maps[randi_range(0,maps.size()-1)]
			iconSprite.map_selected.connect(func(mapPath, location): map_selected.emit(mapPath, location), 2)
			iconSprite.location = Vector2i(i,j)
			sprites[i].append(iconSprite)
			add_child(iconSprite)
			
	for i in range(map.size()):
		if i + 1 == map.size(): break
		var layer = map[i]
		for j in range(layer.size()):
			var distanceFromCenter = proximityToCenter(j, layer)
			var nextLayerDistances = fuzzValues(verticalDistanceFromCenter[i+1])
			
			var neighbors = find_n_closest_indices(distanceFromCenter, nextLayerDistances, numConnectionsForward[i][j])
			
			for k in neighbors:
				drawLine(sprites[i][j].position, sprites[i+1][k].position)
				forwardConnections[i][j].append(k)
				
				numConnectionsBackward[i+1][k] += 1
	
	for i in range(map.size()-1, 0, -1):
		if i == 0: break
		var layer = map[i]
		for j in range(layer.size()):
			if numConnectionsBackward[i][j] == 0:
				var distanceFromCenter = proximityToCenter(j, layer)
				var prevLayerDistances = fuzzValues(verticalDistanceFromCenter[i-1])
				var neighbors = find_n_closest_indices(distanceFromCenter, prevLayerDistances, 1)
				for k in neighbors:
					drawLine(sprites[i][j].position, sprites[i-1][k].position)
					forwardConnections[i-1][k].append(j)
				numConnectionsBackward[i][j] = neighbors.size()
				
	for j in forwardConnections[currentLocation.x][currentLocation.y]:
		sprites[currentLocation.x+1][j].clickable = true
	
	sprites[currentLocation.x][currentLocation.y].scale *= 2

func fuzzValues(array:Array):
	var newArray = array.duplicate()
	for i in range(newArray.size()):
		newArray[i] += randf_range(-0.1,0.1)
		
	return newArray

func drawLine(start_point, end_point):
	# Create a new Line2D node
	var line = Line2D.new()
	line.z_index = -1

	# Set the start and end points of the line
	line.add_point(start_point)
	line.add_point(end_point)

	# Set the line color
	line.default_color = Color(1, 1, 1)  # Set to white color

	# Add the line as a child of this node
	add_child(line)

#GPT wrote this
func findClosestIndex(x: float, values: Array) -> int:
	# Ensure that the array is not empty
	if values.size() == 0:
		return -1  # Return -1 to indicate that the array is empty

	# Initialize variables to keep track of the closest value and its index
	var closest_value = values[0]
	var closest_index = 0

	# Iterate through the array to find the closest value and its index
	for i in range(values.size()):
		var current_value = values[i]
		var current_distance = abs(x - current_value)
		var closest_distance = abs(x - closest_value)

		if current_distance < closest_distance:
			closest_value = current_value
			closest_index = i

	return closest_index

#GPT
func find_n_closest_indices(x: float, array: Array, n: int) -> Array:
	# Ensure that the array is not empty
	if array.size() == 0:
		return []  # Return an empty array to indicate an error or invalid result

	# Create a dictionary to store the indices and their corresponding distances
	var index_distances = {}

	# Calculate the distance of each element in the array from the target value
	for i in range(array.size()):
		var current_value = array[i]
		var current_distance = abs(x - current_value)
		index_distances[i] = current_distance

	var sorted_indices = index_distances.keys()
	# Sort the dictionary by distance in ascending order
	sorted_indices.sort_custom(func(key1, key2): return index_distances[key1] < index_distances[key2])

	var closest_indices = []
	for i in range(min(n, sorted_indices.size())):
		closest_indices.append(sorted_indices.pop_front())

	return closest_indices

# Takes an index and an array and returns how close that index is to the center of the array, with a sign for if it's above or below the center
func proximityToCenter(index: int, array: Array) -> float:
	# Calculate the center index of the array
	var center_index = float(array.size()) / 2

	# Calculate the proximity to the center
	var proximity = index - center_index

	return proximity

var time = 0.0
const PULSE_PERIOD = 2
const PULSE_SIZE = 0.25
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time = wrapf(time+delta/PULSE_PERIOD, -PULSE_SIZE,PULSE_SIZE)
	
	for j in forwardConnections[currentLocation.x][currentLocation.y]:
		sprites[currentLocation.x+1][j].scale = abs(time)*Vector2.ONE + Vector2(1-PULSE_SIZE, 1-PULSE_SIZE)
