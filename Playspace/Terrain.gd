class_name Terrain extends TileMap

const E = -1
const T = -2
const M = -3
const W = -4
const L = -5
const X = -6
const S = -7

#const TrainCar = preload("res://TrainCar.gd")

signal confirmed(confirmed_or_cancelled)
signal building_rail
signal rail_built(built_or_not)
var buildingRail = false
var numRailToBuild = 0
# Which tiles rail is currently allowed to be built on
var buildOver = Global.empty_tiles

var targeting = false

var DIR = Global.DIR
var DIRS = [DIR.U, DIR.R, DIR.D, DIR.L]
var outgoingMap = []
var incomingMap = []
var directionalCellMap = []
var connectedCells:Array[Vector2i] = []
# Contains a map of cells' distances and direction to the railEndpoint for purpose of adding rails
var directionToStartMap = []
var goalCells = []
var legalToPlaceRail = false

var mapShape:Vector2i = Vector2i(0,0)
var revealedTiles:Array[Vector2i] = []
var originalRevealedTiles

var trainLocations:Array[Vector2i]
var railEndpoint:Vector2i
var railStartpoint:Vector2i
var originalRailEndpoint:Vector2i
var partialRailBuilt:Array[Vector2i] = []
var lastRailPlaced:Vector2i

var useEmergencyRail = false

var trainCars:Array[TrainCar] = []
var enemies:Array[Enemy] = []
var spawners:Array[Spawner] = []

var trainCrashed = false
var trainSucceeded = false

@onready var camera = $"../../Camera"
@onready var cardFunctions = $"../CardFunctions"
@onready var PLAYSPACE:Playspace = $".."
@onready var speedometer:Speedometer = $"../../EverywhereUI/Top Bar/TopBar HBox/Speedometer"

var highlighted_cells:Array[Vector2i] = []
var enemyHighlights:Array = []
var spawnerHighlights:Array = []
var pseudohighlighted_cells:Array[Vector2i] = []
var locked_highlights:Array[Vector2i] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(Global.max_layer):
		add_layer(i)
		set_layer_enabled(i, true)
		set_layer_z_index(i,0)
	
	Stats.startLevel()
	var trainFront = TrainCar.new("Front")
	trainFront.scale *= 0.5
	add_child(trainFront)
	trainCars.append(trainFront)
	
	for carName in Stats.trainCars:
		var trainCar = TrainCar.new(carName)
		trainCar.scale *= 0.5
		trainCars.append(trainCar)
		add_child(trainCar)
	
	var trainBack = TrainCar.new("Caboose")
	trainBack.scale *= 0.5
	add_child(trainBack)
	
	trainCars.append(trainBack)
	
	setUpMap()
	
	camera.position = map_to_local(Vector2(railEndpoint)*scale) - (Global.VIEWPORT_SIZE /2)
	
	makeMetalShine()
	
	startTurn()

var pathIndices:Dictionary
func setUpMap():
	var cells
	var cellInfo
	var map:MapRewards = $"../../EverywhereUI/Overworld".currentNode
	var mapName = map.mapName
	Stats.speedRampFunction = Tile.mapDb[mapName][Tile.SpeedRamp]
	if Global.devmode:
		Stats.speedRampFunction = func(x): return 100
	Stats.turnCounter = 0
	Stats.trainSpeed = Stats.speedRampFunction.call(Stats.turnCounter)
	speedometer.populateSpeedometer()
	if map.isMirrored:
		var mirroredInfo = Tile.mirrorMap(mapName)
		cells = mirroredInfo[0]
		cellInfo = mirroredInfo[1]
	else:
		cells = Tile.mapDb[mapName][Tile.Cells]
		cellInfo = Tile.mapDb[mapName][Tile.CellInfo]
	var index = 0
	for i in range(cells.size()):
		var row = cells[i]
		# Positive indices have special values in cellInfo
		if row[-1] < 0:
			continue
		if cellInfo[row[-1]][Tile.Type] == Tile.TYPES.Goal:
			pathIndices[i] = index
			index += 1
	mapShape = Vector2i(cells[0].size(), cells.size())
	for i in range(mapShape.x + trainCars.size()):
		outgoingMap.append([])
		incomingMap.append([])
		directionalCellMap.append([])
		for j in range(mapShape.y):
			outgoingMap[i].append(DIR.NONE)
			incomingMap[i].append(DIR.NONE)
			directionalCellMap[i].append(null)
	
	for x in range(mapShape.x):
		for y in range(mapShape.y):
			# The indexing is backwards because it's row, column (which is y, x)
			var cellEnum = cells[y][x]
			var cellPosition = Vector2i(x, y)
			# Add the grid overlay to everything
			set_cell(Global.grid_layer, cellPosition, 0, Global.grid_outline)
			if cellEnum == W:
				set_cell(0,cellPosition, 0, Global.water)
			elif cellEnum == T:
				set_cell(0,cellPosition, 0, Global.tree)
			elif cellEnum == M:
				set_cell(0,cellPosition, 0, Global.rock)
			elif cellEnum == E:
				set_cell(0,cellPosition, 0, Global.empty)
			elif cellEnum == X:
				var randomTile = [Global.tree, Global.rock, Global.empty]
				set_cell(0, cellPosition, 0, randomTile[randi_range(0,2)])
			elif cellEnum == L:
				railEndpoint = cellPosition
				railStartpoint = cellPosition
				lastRailPlaced = cellPosition
			elif cellEnum == S:
				set_cell(Global.grid_layer, cellPosition, 0, Global.delete)
			#TODO: figure out how to handle existing rail as bidirectional
			else:
				var cell_info = cellInfo[cellEnum]
				if cell_info[Tile.Type] == Tile.TYPES.Rail:
					set_cell_directional(cellPosition, Global.DIRECTIONAL_TILES.RAIL, cell_info[Tile.Directions][0], cell_info[Tile.Directions][1], Global.rail_layer)
					set_cell(Global.base_layer, cellPosition, 0, Global.empty)
				elif cell_info[Tile.Type] == Tile.TYPES.Goal:
					set_cell(Global.base_layer, cellPosition, 0, Global.empty)
					set_cell_directional(cellPosition, Global.DIRECTIONAL_TILES.RAIL_END, cell_info[Tile.Directions][0], cell_info[Tile.Directions][1], Global.rail_layer)
				elif cell_info[Tile.Type] == Tile.TYPES.Spawner:
					set_cell(Global.base_layer, cellPosition, 0, Global.delete)
					var spawner = Spawner.new(cell_info[Tile.SpawnerName], cell_info[Tile.SpawnerCount], cellPosition)
					spawner.scale *= 0.5
					spawner.position = mapPositionToScreenPosition(cellPosition) / scale
					spawner.highlightedCells = radiusAroundCell(cellPosition, spawner.spawnerRadius)
					spawners.append(spawner)
					add_child(spawner)
					spawner.initCounter()
					spawner.drawRangeHighlight.connect(drawSpawnerRange)
					# 1 is code for spawner color
					spawner.clearRangeHighlight.connect(func(): clearHighlights(1))

	
	for i in range(trainCars.size()):
		set_cell(Global.base_layer, railEndpoint + Vector2i(-i,0), 0, Global.empty)
		set_cell_directional(railEndpoint + Vector2i(-i,0), Global.DIRECTIONAL_TILES.RAIL, DIR.L, DIR.R)
		trainCars[i].position = mapPositionToScreenPosition(railEndpoint + Vector2i(-i,0)) / scale
		#trainCars[i].position -= trainCars[i].scale*trainCars[i].size/2
		#trainCars[i].pivot_offset = trainCars[i].size/2
		connectedCells.append(railEndpoint + Vector2i(-i,0))
		trainLocations.append(railEndpoint + Vector2i(-i,0))

func radiusAroundCell(cell, radius):
	var x = cell.x
	var y = cell.y
	var cells = []
	for i in range(x-radius, x+radius+1):
		for j in range(y-radius, y+radius+1):
			cells.append(Vector2i(i,j))
	cells = rejectOutOfBounds(cells)
	return cells

func startTurn():
	for spawner in spawners:
		spawner.chooseAction()
		spawner.spawnIfSpawning()

func spawnEnemy(enemyName:String, enemyLocation:Vector2i):
	var enemy = Enemy.new(enemyName, enemyLocation)
	enemy.scale *= 0.5
	enemy.position = map_to_local(enemy.cell)
	enemies.append(enemy)
	add_child(enemy)
	enemy.initHealthCounter()
	enemy.drawRangeHighlight.connect(drawEnemyRange)
	enemy.clearRangeHighlight.connect(func():clearHighlights(2))
	

func drawEnemyRange(cell, range):
	var range_cells:Array = radiusAroundCell(cell, range)
	enemyHighlights += range_cells
	# 2 is the code for range color
	drawHighlights(range_cells, 2)

func drawSpawnerRange(cell, range):
	var range_cells:Array = radiusAroundCell(cell, range)
	spawnerHighlights += range_cells
	# 2 is the code for range color
	drawHighlights(range_cells, 1)


func shootProjectile(fromCell, toCell):
	var fromPos = map_to_local(fromCell)
	var toPos = map_to_local(toCell)
	await animate_circle(fromPos, toPos, 0.3)

#GPT
# Function to animate the circle from start_pos to end_pos over duration (in seconds)
func animate_circle(start_pos: Vector2, end_pos: Vector2, duration: float):
	var circle_instance = create_circle_instance(start_pos)
	
	var time_passed := 0.0
	
	while time_passed < duration:
		var t = time_passed / duration
		circle_instance.position = start_pos.lerp(end_pos, t)
		circle_instance.queue_redraw()
		time_passed += get_process_delta_time()
		await get_tree().process_frame
	
	circle_instance.position = end_pos
	circle_instance.queue_free()

# Helper function to create and add a red circle instance to the scene
func create_circle_instance(position: Vector2) -> Node2D:
	var circle_instance = Projectile.new()
	circle_instance.position = position
	
	add_child(circle_instance)
	
	return circle_instance

#GPT
func interpolate_quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, num_segments: int = 10) -> Array:
	var curve_points = []

	for i in range(num_segments + 1):
		var t = i / float(num_segments)
		var u = 1.0 - t

		var p = p0 * u * u + p1 * 2 * u * t + p2 * t * t
		curve_points.append(p)
	return curve_points

func moveSpriteAlongPoints(sprite, points:Array, speed):
	for point in points:
		while sprite.position.distance_to(point) > 1:
			var direction = (point - sprite.position).normalized()
			sprite.position += direction * speed
			sprite.rotation = direction.angle()
			await get_tree().create_timer(0.01).timeout
			
func moveSpriteAlongPointsNoRot(sprite, points:Array, speed):
	for point in points:
		while sprite.position.distance_to(point) > 1:
			var direction = (point - sprite.position).normalized()
			sprite.position += direction * speed
			await get_tree().create_timer(0.01).timeout

# If the chicane car reports a chicane, we reduce next turn's speed by 1
var chicane_car_slow = 0

func advanceTrain():
	if trainCrashed or trainSucceeded: return
	
	var emergencyTrackUsed = false
	var stepNumber = 0
	while stepNumber < Stats.trainSpeed:
		var pointsToMoveThrough = {}
		for i in range(trainLocations.size()):
			pointsToMoveThrough[i] = []
		var nextTrainLocations:Array[Vector2i] = []
			
		var recalcEmergency = false
		var numTrainCars = trainLocations.size()
		for i in range(numTrainCars):
			if trainSucceeded or recalcEmergency: continue
			var trainLocation = trainLocations[0]
			var trainIncoming = incomingMap[trainLocation.x][trainLocation.y]
			var trainOutgoing = outgoingMap[trainLocation.x][trainLocation.y]
			#var trainType = directionalCellMap[trainLocation.x][trainLocation.y]
			var nextLocation = Global.stepInDirection(trainLocation, trainOutgoing)
			
			if get_cell_atlas_coords(Global.rail_layer, nextLocation) == Global.rail_endpoint:
				Stats.levelCounter += 1

				PLAYSPACE.levelComplete.emit(pathIndices[nextLocation.y])
				speedometer.removeSpeedometer()
				trainSucceeded = true
				stepNumber = INF
				break
				
			# Some train cars will do something that may avert the emergency.  If so, we will skip the next block
			#The check for emergencyTrackUsed lets us know if we've already allowed some emergency track laying
			if not emergencyTrackUsed and get_cell_atlas_coords(Global.rail_layer, nextLocation) not in Global.rail_tiles:
				if "AutoBuild" in Stats.powersInPlay and (Stats.woodCount > 0 and Stats.metalCount > 0):
					if get_cell_atlas_coords(Global.base_layer, nextLocation) in Global.empty_tiles:
						set_cell_directional(nextLocation, Global.DIRECTIONAL_TILES.RAIL, Global.oppositeDir(trainOutgoing), trainOutgoing, Global.rail_layer)
						Stats.woodCount -= 1
						Stats.metalCount -= 1
						recalcEmergency = true
				
				if not recalcEmergency:
					for trainCar in trainCars:
						if TrainCar.TYPE.EMERGENCY in trainCar.types:
							if trainCar.onEmergency():
								recalcEmergency = true
								break
				
				if not recalcEmergency:
					useEmergencyRail = true
					Global.cardFunctionStarted.emit()
					#Calling through cardFunctions because that displays the text
					cardFunctions.buildRail(Stats.trainSpeed - stepNumber, Global.empty_tiles)
					await rail_built
					Global.cardFunctionEnded.emit()
					trainOutgoing = outgoingMap[trainLocation.x][trainLocation.y]
					nextLocation = Global.stepInDirection(trainLocation, trainOutgoing)
					
					useEmergencyRail = false
					emergencyTrackUsed = true
			
			if recalcEmergency: 
				continue
			
			if get_cell_atlas_coords(Global.rail_layer, nextLocation) not in Global.rail_tiles:
				print("TRAIN CRASHED")
				trainCrashed = true
				return
			
			if TrainCar.TYPE.TRAINMOVEMENT in trainCars[i].types:
				await trainCars[i].onMovement(trainLocation, self)
			
			destroyEnemiesInCells([nextLocation])
			
			# If there is something that can be collected near the train, but not in front, collect it
			match outgoingMap[nextLocation.x][nextLocation.y]:
				Global.DIR.U:
					for x in range(-Stats.pickupRange, Stats.pickupRange + 1):
						for y in range(0, Stats.pickupRange + 1):
							collect(nextLocation + Vector2i(x, y))
				Global.DIR.D:
					for x in range(-Stats.pickupRange, Stats.pickupRange + 1):
						for y in range(-Stats.pickupRange, 1):
							collect(nextLocation + Vector2i(x, y))
				Global.DIR.R:
					for x in range(-Stats.pickupRange, 1):
						for y in range(-Stats.pickupRange, Stats.pickupRange + 1):
							collect(nextLocation + Vector2i(x, y))
				Global.DIR.L:
					for x in range(0, Stats.pickupRange + 1):
						for y in range(-Stats.pickupRange, Stats.pickupRange + 1):
							collect(nextLocation + Vector2i(x, y))
					
			
			var nextOutgoing = outgoingMap[nextLocation.x][nextLocation.y]
			
			var nextPosition = map_to_local(nextLocation)
			var currentPosition = map_to_local(trainLocation)
			var prevPosition = map_to_local(Global.stepInDirection(trainLocation, trainIncoming))
			var nextNextPosition = map_to_local(Global.stepInDirection(nextLocation, nextOutgoing))
			
			const NUM_ANIMATION_POINTS:int = 100
			var firstCurve = interpolate_quadratic_bezier(
				(currentPosition + prevPosition) / 2,
				currentPosition,
				(currentPosition + nextPosition) / 2,
				NUM_ANIMATION_POINTS
			)
			var secondCurve = interpolate_quadratic_bezier(
				(nextPosition + currentPosition) /2,
				nextPosition,
				(nextPosition + nextNextPosition) /2,
				NUM_ANIMATION_POINTS
			)
			
			for _i in range(NUM_ANIMATION_POINTS / 3):
				pointsToMoveThrough[i].append(firstCurve[_i+2*NUM_ANIMATION_POINTS/3])
			
			for _i in range(NUM_ANIMATION_POINTS / 2):
				pointsToMoveThrough[i].append(secondCurve[_i])
			
			trainLocations.pop_front()
			nextTrainLocations.append(nextLocation)
	
		if not (trainSucceeded or recalcEmergency):
			trainLocations = nextTrainLocations
			await moveTrainCarsAlongPoints(pointsToMoveThrough, 1.0)
			stepNumber += 1
	
	if Stats.speedAdjustments.size() < 1:
		Stats.speedAdjustments.append(0)
	Stats.speedAdjustments[0] += chicane_car_slow
	speedometer.progressTurn()
	
	chicane_car_slow = 0

var enemiesMoved = 0

func destroyEnemiesInCells(cells:Array):
	var enemiesToRemove = []
	for enemyIndex in range(len(enemies)):
		var enemy = enemies[enemyIndex]
		if enemy.cell in cells:
			enemiesToRemove.append(enemy)
			enemy.queue_free()
			
	for enemy in enemiesToRemove:
		enemy.destroy(true)

func destroyEnemy(enemy:Enemy):
	var index = enemies.find(enemy)
	if index != -1:
		enemies.remove_at(index)
		enemy.queue_free()

func getEnemyAndSpawnerCells():
	var cells = []
	for enemy in enemies:
		cells.append(enemy.cell)
	for spawner in spawners:
		cells.append(spawner.cell)
		
	return cells

func getOccupiedCells():
	return getEnemyAndSpawnerCells() + trainLocations

#TODO: This definitely doesn't work right for non linear paths, so fix that
func moveSpriteThroughCellsNoRot(sprite:Node2D, cellPath, dirPath):
	for i in range(1,len(cellPath)):
		var pointsToMoveThrough = []
		var cell = cellPath[i]
		var dir = dirPath[i]
		var currentPosition = map_to_local(cell)
		var prevPosition = map_to_local(Global.stepInDirection(cell, Global.oppositeDir(dir)))
		if i == 0:
			prevPosition = currentPosition
		var nextPosition = map_to_local(Global.stepInDirection(cell, dir))
		var nextNextPosition = map_to_local(Global.stepInDirection(cellPath[i+1], dirPath[i+1])) if i < len(cellPath)-1 else map_to_local(Global.stepInDirection(Global.stepInDirection(cell, dir), dir))
		
		const NUM_ANIMATION_POINTS:int = 100
		
		var firstCurve = interpolate_quadratic_bezier(
			prevPosition,
			(prevPosition + currentPosition) / 2,
			currentPosition,
			NUM_ANIMATION_POINTS
		)
		#var secondCurve = interpolate_quadratic_bezier(
			#(nextPosition + currentPosition) /2,
			#nextPosition,
			#(nextPosition + nextNextPosition) /2,
			#NUM_ANIMATION_POINTS
		#)w
		
		for _i in range(NUM_ANIMATION_POINTS / 3):
			pointsToMoveThrough.append(firstCurve[_i+2*NUM_ANIMATION_POINTS/3])
		
		#for _i in range(NUM_ANIMATION_POINTS / 2):
			#pointsToMoveThrough.append(secondCurve[_i])
		
		await moveSpriteAlongPointsNoRot(sprite, pointsToMoveThrough, 1.0)
		
	enemiesMoved += 1
		
	

func enemyTurn():
	# Remove enemy range highlights
	clearHighlights(true)
	enemies.shuffle()
	for enemy in enemies:
		var enemyReturn = await enemy.takeActions()
		enemy.startMoving()
		await moveSpriteThroughCellsNoRot(enemy, enemyReturn[0], enemyReturn[1])
		enemy.afterMoveActions()
		
	while enemiesMoved < len(enemies):
		await get_tree().create_timer(0.1).timeout
	
	enemiesMoved = 0
	
func spawnerTurn():
	for spawner in spawners:
		spawner.endTurnAction()

func moveTrainCarsAlongPoints(pointsToMoveThrough, speed):
	var i = 0
	while i < trainCars.size() - 1:
		moveSpriteAlongPoints(trainCars[i], pointsToMoveThrough[i], 1.0)
		i += 1
	
	await moveSpriteAlongPoints(trainCars[i], pointsToMoveThrough[i], 1.0)

func collect(cell):
	match get_cell_atlas_coords(0, cell):
		Global.wood:
			Stats.woodCount += 1
			set_cell(0, cell, 0, Global.empty)
		Global.metal:
			Stats.metalCount += 1
			set_cell(0, cell, 0, Global.empty)
			
func randomTerrainVector():
	var selection = randi_range(0,2)
	if selection == 0:
		return Global.tree
	elif selection == 1:
		return Global.rock
	else:
		return Global.empty

func clearHighlights(type:int=0):
	# spawner
	if type == 1:
		for cell in spawnerHighlights:
			set_cell(Global.spawner_highlight_layer,cell, 0, Global.delete)
	# enemy
	elif type == 2:
		for cell in enemyHighlights:
			set_cell(Global.range_highlight_layer,cell, 0, Global.delete)
	else:
		for cell in highlighted_cells:
			if cell not in locked_highlights:
				set_cell(Global.highlight_layer,cell, 0, Global.delete)
		
		highlighted_cells.clear()
	
func clearPseudoHighlights():
	pseudohighlighted_cells.clear()
			
func clearLockedHighlights():
	for cell in locked_highlights:
		if cell not in highlighted_cells:
			set_cell(Global.highlight_layer,cell, 0, Global.delete)
	locked_highlights.clear()
			
			
func screenPositionToMapPosition(screenPosition):
	return local_to_map((screenPosition + camera.position) / scale)
	
func mapPositionToScreenPosition(mapPosition:Vector2i):
	return map_to_local(mapPosition)*scale - camera.position
	

func target(acceptHighlight:Callable = func(_tiles): return true) :
	self.acceptHighlight = acceptHighlight
	targeting = true
	

# These are useful for powers that need to expand on the area that was previously highlighted
var lastHighlightedMousePosition
var lastHighlightedTargetArea:Vector2i
var lastPseudoHighlightedMousePosition
var lastPseudoHighlightedTargetArea
var pseudoHighlightedCells

var acceptHighlight:Callable = func(_tile): return true

# returns true if all highlighted tiles are within the map
func checkInBounds(currently_highlighted_tiles):
	for highlighted_tile in currently_highlighted_tiles:
		if not( 0 <= highlighted_tile[0] \
			and highlighted_tile[0] < mapShape[0] \
			and 0 <= highlighted_tile[1] \
			and highlighted_tile[1] < mapShape[1]):
				return false
	
	return true

# Takes an array of coordinates and returns those which are in bounds
func rejectOutOfBounds(tiles):
	var acceptedTiles = []
	for tile in tiles:
		if  0 <= tile[0] \
			and tile[0] < mapShape[0] \
			and 0 <= tile[1] \
			and tile[1] < mapShape[1]:
				acceptedTiles.append(tile)
	
	return acceptedTiles

# Draws the highlight and updates which cells are highlighted
func highlightCells(mousePosition, targetArea:Vector2i, fromTopLeft:bool=false):
	clearHighlights()
	
	lastHighlightedMousePosition = mousePosition
	lastHighlightedTargetArea = targetArea

	var currently_highlighted_tiles:Array[Vector2i] = []
			
	var center_tile = screenPositionToMapPosition(mousePosition)
	currently_highlighted_tiles.append(center_tile)
	
	if fromTopLeft:
		for i in range(targetArea.x):
			for j in range(targetArea.y):
				currently_highlighted_tiles.append(Vector2i(i,j) + center_tile)
		
	else:
		var spreadX = targetArea.x/2
		var spreadY = targetArea.y/2
		
		# i will be 0-indexed, so we add an extra tile for odd spread.
		# For event spread, 
		# adding i + 0.5 will only add the closest tiles.
		# For instance, at 0.75, it adds only the right tile, not the left
		var addX = 1.0 if targetArea.x % 2 == 1 else 0.5
		var addY = 1.0 if targetArea.y % 2 == 1 else 0.5
		
		for i in range(-1,spreadX):
			for j in range(-1,spreadY):
				currently_highlighted_tiles.append(screenPositionToMapPosition(
					mousePosition + Vector2(
						(addX + i)*tile_set.tile_size.x*scale.x, 
						(addY + j)*tile_set.tile_size.y*scale.y)))
				currently_highlighted_tiles.append(screenPositionToMapPosition(
					mousePosition + Vector2(
						-1*(addX + i)*tile_set.tile_size.x*scale.x, 
						(addY + j)*tile_set.tile_size.y*scale.y)))
				currently_highlighted_tiles.append(screenPositionToMapPosition(
					mousePosition + Vector2(
						-1*(addX + i)*tile_set.tile_size.x*scale.x, 
						-1*(addY + j)*tile_set.tile_size.y*scale.y)))
				currently_highlighted_tiles.append(screenPositionToMapPosition(
					mousePosition + Vector2(
						(addX + i)*tile_set.tile_size.x*scale.x, 
						-1*(addY + j)*tile_set.tile_size.y*scale.y)))
	currently_highlighted_tiles = remove_duplicates(currently_highlighted_tiles)
	
	if checkInBounds(currently_highlighted_tiles) and acceptHighlight.call(currently_highlighted_tiles):
		highlighted_cells = currently_highlighted_tiles
		drawHighlights(highlighted_cells)
	
	pseudoHighlightedCells = currently_highlighted_tiles

func remove_duplicates(array: Array[Vector2i]) -> Array[Vector2i]:
	var result:Array[Vector2i] = []  # The resulting array with duplicates removed
	
	for item in array:
		if item not in result:
			result.append(item)
	
	return result

# Draws the highlight and updates which cells are highlighted
func pseudoHighlightCells(mousePosition, targetArea:Vector2i, fromTopLeft:bool=false):
	clearPseudoHighlights()
	
	lastPseudoHighlightedMousePosition = mousePosition
	lastPseudoHighlightedTargetArea = targetArea

	var currently_highlighted_tiles:Array[Vector2i] = []
			
	var center_tile = screenPositionToMapPosition(mousePosition)
	currently_highlighted_tiles.append(center_tile)
	
	if fromTopLeft:
		for i in range(targetArea.x):
			for j in range(targetArea.y):
				currently_highlighted_tiles.append(Vector2i(i,j) + center_tile)
		
	else:
		var spreadX = targetArea.x/2
		var spreadY = targetArea.y/2
		
		# i will be 0-indexed, so we add an extra tile for odd spread.
		# For event spread, 
		# adding i + 0.5 will only add the closest tiles.
		# For instance, at 0.75, it adds only the right tile, not the left
		var addX = 1.0 if targetArea.x % 2 == 1 else 0.5
		var addY = 1.0 if targetArea.y % 2 == 1 else 0.5
		
		for i in range(-1,spreadX):
			for j in range(-1,spreadY):
				currently_highlighted_tiles.append(screenPositionToMapPosition(
					mousePosition + Vector2(
						(addX + i)*tile_set.tile_size.x*scale.x, 
						(addY + j)*tile_set.tile_size.y*scale.y)))
				currently_highlighted_tiles.append(screenPositionToMapPosition(
					mousePosition + Vector2(
						-1*(addX + i)*tile_set.tile_size.x*scale.x, 
						(addY + j)*tile_set.tile_size.y*scale.y)))
				currently_highlighted_tiles.append(screenPositionToMapPosition(
					mousePosition + Vector2(
						-1*(addX + i)*tile_set.tile_size.x*scale.x, 
						-1*(addY + j)*tile_set.tile_size.y*scale.y)))
				currently_highlighted_tiles.append(screenPositionToMapPosition(
					mousePosition + Vector2(
						(addX + i)*tile_set.tile_size.x*scale.x, 
						-1*(addY + j)*tile_set.tile_size.y*scale.y)))
		
	var containsOutOfBoundsCell = false
	for highlighted_tile in currently_highlighted_tiles:
		if not( 0 <= highlighted_tile[0] \
			and highlighted_tile[0] < mapShape[0] \
			and 0 <= highlighted_tile[1] \
			and highlighted_tile[1] < mapShape[1]):
				containsOutOfBoundsCell = true
	
	pseudoHighlightedCells = currently_highlighted_tiles

# enemy color 0 = highlight, 1 = spawner, 2 = enemyrange
func drawHighlights(cells, enemyColor:int = 0):
	var highlight_single = Global.highlight
	var highlight_l = Global.highlight_l
	var highlight_r = Global.highlight_r
	var highlight_u = Global.highlight_u
	var highlight_d = Global.highlight_d
	var highlight_lu = Global.highlight_lu
	var highlight_ld = Global.highlight_ld
	var highlight_ru = Global.highlight_ru
	var highlight_rd = Global.highlight_rd
	var layer = Global.highlight_layer
	
	if enemyColor == 1:
		highlight_single = Global.spawner_highlight
		highlight_l = Global.spawner_highlight_l
		highlight_r = Global.spawner_highlight_r
		highlight_u = Global.spawner_highlight_u
		highlight_d = Global.spawner_highlight_d
		highlight_lu = Global.spawner_highlight_lu
		highlight_ld = Global.spawner_highlight_ld
		highlight_ru = Global.spawner_highlight_ru
		highlight_rd = Global.spawner_highlight_rd
		layer = Global.spawner_highlight_layer
	elif enemyColor == 2:
		highlight_single = Global.range_highlight
		highlight_l = Global.range_highlight_l
		highlight_r = Global.range_highlight_r
		highlight_u = Global.range_highlight_u
		highlight_d = Global.range_highlight_d
		highlight_lu = Global.range_highlight_lu
		highlight_ld = Global.range_highlight_ld
		highlight_ru = Global.range_highlight_ru
		highlight_rd = Global.range_highlight_rd
		layer = Global.range_highlight_layer
	
	if cells.size() == 1:
		set_cell(layer, cells[0], 0, highlight_single)
	else:
		var highest_x = -INF
		var lowest_x = INF
		var highest_y = -INF
		var lowest_y = INF
		for cell in cells:
			highest_x = max(cell.x, highest_x)
			highest_y = max(cell.y, highest_y)
			lowest_y = min(cell.y, lowest_y)
			lowest_x = min(cell.x, lowest_x)
			
		for cell in cells:
			if cell.x == highest_x:
				if cell.y == lowest_y:
					set_cell(layer, cell, 0, highlight_ru)
				elif cell.y == highest_y:
					set_cell(layer, cell, 0, highlight_rd)
				else:
					set_cell(layer, cell, 0, highlight_r)
			elif cell.x == lowest_x:
				if cell.y == lowest_y:
					set_cell(layer, cell, 0, highlight_lu)
				elif cell.y == highest_y:
					set_cell(layer, cell, 0, highlight_ld)
				else:
					set_cell(layer, cell, 0, highlight_l)
					
			elif cell.y == lowest_y:
				set_cell(layer, cell, 0, highlight_u)
			elif cell.y == highest_y:
				set_cell(layer, cell, 0, highlight_d)
	

func buildRail(numRail, buildOver:Array):
	self.buildOver = buildOver
	if Global.devmode:
		self.buildOver = Global.harvestable + Global.gatherable + Global.empty_tiles + [Global.water]
	emit_signal("building_rail")
	originalRailEndpoint = railEndpoint
	originalRevealedTiles = revealedTiles
	if useEmergencyRail and Stats.emergencyRailCount > 0:
		buildingRail = true
		numRailToBuild = min(numRail, Stats.emergencyRailCount)
		highlightCells(get_viewport().get_mouse_position(), Vector2i.ONE)
		return true
	elif !useEmergencyRail and Stats.metalCount > 0 and Stats.woodCount > 0:
		buildingRail = true
		numRailToBuild = min(numRail, Stats.metalCount, Stats.woodCount)
		highlightCells(get_viewport().get_mouse_position(), Vector2i.ONE)
		return true
	else:
		self.buildOver = Global.empty_tiles
		rail_built.emit(Global.FUNCTION_STATES.Fail)
		return false

func set_cell_directional(mapPosition, cellType, incoming, outgoing, layer = Global.rail_layer):
	var directional_info = Global.DIRECTIONAL_TILE_INOUT[cellType][incoming][outgoing]
	
	set_cell(layer, mapPosition, 0, directional_info[0], directional_info[1])
	directionalCellMap[mapPosition.x][mapPosition.y] = cellType
	incomingMap[mapPosition.x][mapPosition.y] = incoming
	outgoingMap[mapPosition.x][mapPosition.y] = outgoing

func changeOutgoing(mapPosition, direction, layer = Global.rail_layer):
	if mapPosition.x < directionalCellMap.size() \
		and mapPosition.y  < directionalCellMap[0].size() \
		and directionalCellMap[mapPosition.x][mapPosition.y] != null:
			if direction == incomingMap[mapPosition.x][mapPosition.y]:
				swapInOut(mapPosition, layer)
			else:
				set_cell_directional(mapPosition, directionalCellMap[mapPosition.x][mapPosition.y],
						incomingMap[mapPosition.x][mapPosition.y],
						direction, layer)
			return true
	else:
		return false

func changeIncoming(mapPosition, direction):
	if mapPosition.x < directionalCellMap.size() \
		and mapPosition.y  < directionalCellMap[0].size() \
		and directionalCellMap[mapPosition.x][mapPosition.y] != null:
			if direction == outgoingMap[mapPosition.x][mapPosition.y]:
				swapInOut(mapPosition)
			else:
				set_cell_directional(mapPosition, directionalCellMap[mapPosition.x][mapPosition.y],
						direction,
						outgoingMap[mapPosition.x][mapPosition.y])
			return true
	else:
		return false

func get_tile(mapPosition:Vector2i):
	return Vector2i(mapPosition / Global.TILE_SHAPE)

func buildRailOn(mousePosition):
	if legalToPlaceRail:
		var mapPosition:Vector2i = screenPositionToMapPosition(mousePosition)
		var amountAdded = addRailLineToMap(railEndpoint, mapPosition, Global.rail_layer)
		recalculateRailRoute()
		lastRailPlaced = mapPosition
		numRailToBuild -= amountAdded
		if useEmergencyRail:
			Stats.emergencyRailCount -= amountAdded
		else:
			Stats.woodCount -= amountAdded
			Stats.metalCount -= amountAdded

func swapInOut(location, layer = Global.rail_layer):
	set_cell_directional(location, directionalCellMap[location.x][location.y], outgoingMap[location.x][location.y], incomingMap[location.x][location.y], layer)

# Traces rail route to determine which tiles are connected and where the endpoint is
# If clearUnderRail is set, it will replace anything that isn't an empty tile underneath the rails with an empty tile
func recalculateRailRoute(clearUnderRail:bool = false):
	connectedCells = []
	var currentPosition:Vector2i = railStartpoint
	var prev_outgoing = DIR.R
	while get_cell_atlas_coords(Global.rail_layer, currentPosition) in Global.rail_tiles:
		if clearUnderRail:
			if get_cell_atlas_coords(Global.base_layer, currentPosition) not in Global.empty_tiles:
				set_cell(Global.base_layer, currentPosition, 0, Global.empty)
		connectedCells.append(currentPosition)
		changeIncoming(currentPosition, Global.oppositeDir(prev_outgoing))
		prev_outgoing = outgoingMap[currentPosition.x][currentPosition.y]
		railEndpoint = currentPosition
		
		# If the next cell is an endpoint, don't continue the line
		if get_cell_atlas_coords(Global.rail_layer, Global.stepInDirection(currentPosition, outgoingMap[currentPosition.x][currentPosition.y])) == Global.rail_endpoint:
			break
			
		currentPosition = Global.stepInDirection(currentPosition, outgoingMap[currentPosition.x][currentPosition.y])
		if currentPosition in connectedCells:
			break
		if currentPosition.x >= len(outgoingMap) or currentPosition.y >= len(outgoingMap[0]):
			break 
			
		#If the cell is a rail connected on both sides, but neither side is part of the connected cells, can't continue the line
		if get_cell_atlas_coords(0, Global.stepInDirection(currentPosition, outgoingMap[currentPosition.x][currentPosition.y])) in Global.rail_tiles \
			and get_cell_atlas_coords(Global.rail_layer, Global.stepInDirection(currentPosition, incomingMap[currentPosition.x][currentPosition.y])) in Global.rail_tiles:
				if not (
					Global.stepInDirection(currentPosition, outgoingMap[currentPosition.x][currentPosition.y]) in connectedCells
					or
					Global.stepInDirection(currentPosition, incomingMap[currentPosition.x][currentPosition.y]) in connectedCells
					):
						break
		#If this cell has an outgoing connection to a new part of existing rail line, it's fine to continue to use that,
		#so we continue, skipping the next check to reverse the direction
		if get_cell_atlas_coords(Global.rail_layer, Global.stepInDirection(currentPosition, outgoingMap[currentPosition.x][currentPosition.y])) in Global.rail_tiles:
			if Global.stepInDirection(currentPosition, outgoingMap[currentPosition.x][currentPosition.y]) not in connectedCells:
				continue
		#If this cell's incoming is a rail that's not currently part of the connected line, reverse its direction
		#(this allows for connecting to either side of an existing rail line)
		if get_cell_atlas_coords(Global.rail_layer, Global.stepInDirection(currentPosition, incomingMap[currentPosition.x][currentPosition.y])) in Global.rail_tiles:
			if Global.stepInDirection(currentPosition, incomingMap[currentPosition.x][currentPosition.y]) not in connectedCells:
				swapInOut(currentPosition)

func resetPartialRail():
	for rail in partialRailBuilt:
		set_cell(Global.rail_layer, rail, 0, -Vector2i.ONE)
		outgoingMap[rail.x][rail.y] = DIR.NONE
		incomingMap[rail.x][rail.y] = DIR.NONE
		directionalCellMap[rail.x][rail.y] = null
		Stats.woodCount += 1
		Stats.metalCount += 1
	partialRailBuilt.clear()
	revealedTiles = originalRevealedTiles
	recalculateRailRoute()
	

func toggleRailOutput(mousePosition):
	var clicked_cell = screenPositionToMapPosition(mousePosition)
	if clicked_cell == lastRailPlaced:
		if clicked_cell.x < outgoingMap.size() and clicked_cell.y < outgoingMap[clicked_cell.x].size():
			var nextDir = Global.nextDirClockwise(outgoingMap[clicked_cell.x][clicked_cell.y])
			if nextDir == incomingMap[clicked_cell.x][clicked_cell.y]:
				nextDir = Global.nextDirClockwise(nextDir)
				
			changeOutgoing(clicked_cell, nextDir, Global.rail_layer)
	
	recalculateRailRoute()


func drawRailLine(startLoc:Vector2i, endLoc:Vector2i, distance:int):
	directionToStartMap = []
	legalToPlaceRail = false
	if get_cell_atlas_coords(0, endLoc) not in buildOver:
		return
	
	for i in range(mapShape.x):
		directionToStartMap.append([])
		for j in range(mapShape.y):
			directionToStartMap[i].append(null)
	
	var outermostLocations = [startLoc]
	directionToStartMap[startLoc.x][startLoc.y] = [incomingMap[startLoc.x][startLoc.y],0]
	var steps = 0
	
	while directionToStartMap[endLoc.x][endLoc.y] == null:
		steps += 1
		if steps > distance:
			break
		var nextOutermost = []
		for loc in outermostLocations:
			for dir in DIRS:
				var nextLoc = Global.stepInDirection(loc, dir)
				if get_cell_atlas_coords(0, nextLoc) in buildOver \
					and get_cell_atlas_coords(Global.rail_layer, nextLoc) not in Global.rail_tiles \
					and directionToStartMap[nextLoc.x][nextLoc.y] == null:
						directionToStartMap[nextLoc.x][nextLoc.y] = [Global.oppositeDir(dir), steps]
						nextOutermost.append(nextLoc)
				
		outermostLocations = nextOutermost
		
	legalToPlaceRail = directionToStartMap[endLoc.x][endLoc.y] != null
	addRailLineToMap(startLoc, endLoc, Global.temporary_rail_layer)

#Returns amount of rail added
func addRailLineToMap(startLoc, endLoc, layer):
	# Prevents a bug where it tries to find a path to start based on old map, when card is clicked
	if directionToStartMap == []: return 0
	if get_cell_atlas_coords(0, endLoc) not in buildOver:
		return 0
		
	var directionMap = directionToStartMap.duplicate(true)
	if directionMap[endLoc.x][endLoc.y] == null:
		return 0
	
	var recordTempRail = false
	if layer == Global.rail_layer:
		recordTempRail = true

	var currentLoc = endLoc
	var currentDir = (directionMap[currentLoc.x][currentLoc.y])[0]
	var currentCellVals = Global.DIRECTIONAL_TILE_INOUT[Global.DIRECTIONAL_TILES.RAIL][currentDir][Global.oppositeDir(currentDir)]
	set_cell(layer, currentLoc, 0, currentCellVals[0], currentCellVals[1])
	if recordTempRail:
		incomingMap[currentLoc.x][currentLoc.y] = currentDir
		outgoingMap[currentLoc.x][currentLoc.y] = Global.oppositeDir(currentDir)
		directionalCellMap[currentLoc.x][currentLoc.y] = Global.DIRECTIONAL_TILES.RAIL
	while currentLoc != startLoc:
		if recordTempRail:
			partialRailBuilt.append(currentLoc)
		currentDir = (directionMap[currentLoc.x][currentLoc.y])[0]
		var nextLoc = Global.stepInDirection(currentLoc, currentDir)
		var nextDir = (directionMap[nextLoc.x][nextLoc.y])[0]
		var nextCellVals = Global.DIRECTIONAL_TILE_INOUT[Global.DIRECTIONAL_TILES.RAIL][nextDir][Global.oppositeDir(currentDir)]
		if recordTempRail:
			incomingMap[nextLoc.x][nextLoc.y] = nextDir
			outgoingMap[nextLoc.x][nextLoc.y] = Global.oppositeDir(currentDir)
			directionalCellMap[nextLoc.x][nextLoc.y] = Global.DIRECTIONAL_TILES.RAIL
		#if recordTempRail or (not nextLoc == startLoc):
		set_cell(layer, nextLoc, 0, nextCellVals[0], nextCellVals[1])
		set_cell(layer, nextLoc, 0, nextCellVals[0], nextCellVals[1])
		if nextLoc == startLoc:
			set_cell(Global.rail_layer, nextLoc, 0, nextCellVals[0], nextCellVals[1])
		currentLoc = nextLoc
		
	return (directionMap[endLoc.x][endLoc.y])[1]

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if buildingRail:
					toggleRailOutput(get_viewport().get_mouse_position())
					clear_layer(Global.temporary_rail_layer)
					if numRailToBuild > 0 and screenPositionToMapPosition(event.position) != lastRailPlaced:
						buildRailOn(get_viewport().get_mouse_position())
						if numRailToBuild == 0:
							clearHighlights()
				
	if event is InputEventMouseMotion:
		clear_layer(Global.temporary_rail_layer)
		if numRailToBuild > 0:
			highlightCells(event.position, Vector2i.ONE)
			if screenPositionToMapPosition(event.position) != lastRailPlaced:
				drawRailLine(railEndpoint, screenPositionToMapPosition(event.position), numRailToBuild)
		
	if event is InputEventKey and buildingRail:
		clear_layer(Global.temporary_rail_layer)
		if event.key_label == KEY_ESCAPE:
			if event.pressed:
				buildingRail = false
				directionToStartMap = []
				numRailToBuild = 0
				resetPartialRail()
				buildOver = Global.empty_tiles
				rail_built.emit(Global.FUNCTION_STATES.Fail)
		if event.key_label == KEY_ENTER:
			if event.pressed:
				buildingRail = false
				directionToStartMap = []
				numRailToBuild = 0
				partialRailBuilt.clear()
				buildOver = Global.empty_tiles
				# Recalculates the rail route and sets anything under the rails to empty
				recalculateRailRoute(true)
				rail_built.emit(Global.FUNCTION_STATES.Success)
		
	
	if event is InputEventKey and targeting:
		if event.key_label == KEY_ESCAPE:
			if event.pressed:
				confirmed.emit(Global.FUNCTION_STATES.Fail)
		
		if event.key_label == KEY_ENTER:
			if event.pressed:
				confirmed.emit(Global.FUNCTION_STATES.Success)

				
	if event is InputEventMouseButton and targeting and highlighted_cells.size() > 0:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				confirmed.emit(Global.FUNCTION_STATES.Success)
				
func makeMetalShine():
	var shine_time = 0.15
	var shine_period = 2.5
	while true:
		await get_tree().create_timer(shine_period).timeout
		var metal_cells = get_used_cells_by_id(Global.base_layer, 0, Global.metal)
		
		for cell in metal_cells:
			set_cell(Global.animation_layer, cell, 0, Global.metal_shine1)
			
		
			
		await get_tree().create_timer(shine_time).timeout
		
		for cell in metal_cells:
			set_cell(Global.animation_layer, cell, 0, Global.metal_shine2)
			
		await get_tree().create_timer(shine_time).timeout
		
		for cell in metal_cells:
			set_cell(Global.animation_layer, cell, 0, Global.delete)
		
		await get_tree().create_timer(shine_time*2).timeout
		
		metal_cells = get_used_cells_by_id(Global.base_layer, 0, Global.metal)
		for cell in metal_cells:
			set_cell(Global.animation_layer, cell, 0, Global.metal_shine1)
			
		await get_tree().create_timer(shine_time).timeout
		
		for cell in metal_cells:
			set_cell(Global.animation_layer, cell, 0, Global.metal_shine2)
			
		await get_tree().create_timer(shine_time).timeout
		
		for cell in metal_cells:
			set_cell(Global.animation_layer, cell, 0, Global.delete)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
