class_name Terrain extends TileMap

enum {E, T, M, R, W, L, G, X}

signal confirmed(confirmed_or_cancelled)
signal building_rail
signal rail_built(built_or_not)
var buildingRail = false
var numRailToBuild = 0

var targeting = false

var DIR = Global.DIR
var DIRS = [DIR.U, DIR.R, DIR.D, DIR.L]
var outgoingMap = []
var incomingMap = []
var directionalCellMap = []
var connectedCells:Array[Vector2i] = []
# Contains a map of cells' distances and direction to the railEndpoint for purpose of adding rails
var directionToStartMap = []
var legalToPlaceRail = false

var fullMapShape:Vector2i = Vector2i(0,0)
var revealedTiles:Array[Vector2i] = []
var originalRevealedTiles
var map:MapBase
var turnCounter = 0

var trainLocations:Array[Vector2i]
var railEndpoint:Vector2i
var railStartpoint:Vector2i
var originalRailEndpoint:Vector2i
var partialRailBuilt:Array[Vector2i] = []
var lastRailPlaced:Vector2i

var useEmergencyRail = false

var trainCars = []


var trainCrashed = false

@onready var fixedElements = $"../FixedElements"
@onready var cardFunctions = $"../CardFunctions"
@onready var PLAYSPACE = $".."

var highlighted_cells:Array[Vector2i] = []
var locked_highlights:Array[Vector2i] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	for i in range(5):
		add_layer(i)
		set_layer_enabled(i, true)
		set_layer_z_index(i,0)
			

func setMap(mapName):
	var trainFront = Sprite2D.new()
	trainFront.centered = true
	trainFront.texture = load("res://Assets/Icons/Train_front.png")
	trainFront.scale *= 0.75
	add_child(trainFront)
	
	var trainMiddle = Sprite2D.new()
	trainMiddle.centered = true
	trainMiddle.texture = load("res://Assets/Icons/Train_middle.png")
	trainMiddle.scale *= 0.75
	add_child(trainMiddle)
	
	var trainBack = Sprite2D.new()
	trainBack.centered = true
	trainBack.texture = load("res://Assets/Icons/Train_back.png")
	trainBack.scale *= 0.75
	add_child(trainBack)
	
	trainCars = [trainFront, trainMiddle, trainBack]
	
	map = load("res://Mapping/" + mapName + ".gd").new()
	
	setUpMap()
	
	fixedElements.position = map_to_local(Vector2(railEndpoint)*scale) - (fixedElements.size /2)*fixedElements.scale
	
	Stats.trainSpeed = map.speedProgression[turnCounter]
	Stats.nextTrainSpeed = map.speedProgression[turnCounter + 1]
	
	makeMetalShine()

func setUpMap():
	var tiles:Array[Tile] = []
	for tileOptions in map.tiles:
		tileOptions.options.shuffle()
		tiles.append(tileOptions.options[0])
	
	fullMapShape = Vector2i(map.shape.x*Global.TILE_SHAPE.x, map.shape.y*Global.TILE_SHAPE.y)
	for i in range(fullMapShape.x):
		outgoingMap.append([])
		incomingMap.append([])
		directionalCellMap.append([])
		for j in range(fullMapShape.y + trainCars.size()):
			outgoingMap[i].append(DIR.NONE)
			incomingMap[i].append(DIR.NONE)
			directionalCellMap[i].append(null)
	
	# Draws the tiles in order starting from the top left
	for i in range(map.shape.x):
		for j in range(map.shape.y):
			var tile:Tile = tiles.pop_front()
			var tile_cells:Array[Array] = tile.cells
			var tile_directions:Array[Array] = tile.directions
			for x in range(Global.TILE_SHAPE.x):
				for y in range(Global.TILE_SHAPE.y):
					# The indexing is backwards because it's row, column (which is y, x)
					var cellEnum = tile_cells[y][x]
					var cellDirections = tile_directions[y][x]
					var cellPosition = Vector2i(i*Global.TILE_SHAPE.x + x, j*Global.TILE_SHAPE.y + y)
					if cellEnum == W:
						set_cell(0,cellPosition, 0, Global.water)
					elif cellEnum == T:
						set_cell(0,cellPosition, 0, Global.tree)
					elif cellEnum == M:
						set_cell(0,cellPosition, 0, Global.rock)
					elif cellEnum == E:
						set_cell(0,cellPosition, 0, Global.empty)
					#TODO: figure out how to handle existing rail as bidirectional
					elif cellEnum == R:
						set_cell_directional(cellPosition, Global.DIRECTIONAL_TILES.RAIL, cellDirections[0], cellDirections[1])
					elif cellEnum == L:
						railEndpoint = cellPosition
						railStartpoint = cellPosition
						lastRailPlaced = cellPosition
					elif cellEnum == G:
						set_cell_directional(cellPosition, Global.DIRECTIONAL_TILES.RAIL_END, cellDirections[0], cellDirections[1])
					elif cellEnum == X:
						var randomTile = [Global.tree, Global.rock, Global.empty]
						set_cell(0, cellPosition, 0, randomTile[randi_range(0,2)])
						
	for i:int in range(fullMapShape.x):
		for j:int in range(fullMapShape.y):
			#Cover in fog
			set_cell(Global.fog_layer, Vector2i(i,j), 0, Global.fog)
			
	revealedTiles.append(map.startTile)
	revealTiles()
	
	for i in range(trainCars.size()):
		set_cell_directional(railEndpoint + Vector2i(0,i), Global.DIRECTIONAL_TILES.RAIL, DIR.D, DIR.U)
		trainCars[i].position = mapPositionToScreenPosition(railEndpoint + Vector2i(0,i)) / scale
		connectedCells.append(railEndpoint + Vector2i(0,i))
		trainLocations.append(railEndpoint + Vector2i(0,i))

func revealTiles():
	for revealedTile in revealedTiles:
		for i in range(Global.TILE_SHAPE.x):
			for j in range(Global.TILE_SHAPE.y):
				set_cell(Global.fog_layer, Vector2i(
					i + Global.TILE_SHAPE.x*revealedTile.x,
					j + Global.TILE_SHAPE.y*revealedTile.y
					), 0, Global.delete)
						

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
			sprite.rotation = direction.angle() + PI/2
			await get_tree().create_timer(0.01).timeout

func advanceTrain():
	if trainCrashed: return
	
	var emergencyTrackUsed = false
	var pointsToMoveThrough = {}
	for i in range(trainLocations.size()):
		pointsToMoveThrough[i] = []
	for stepNumber in range(Stats.trainSpeed):
		var nextTrainLocations:Array[Vector2i] = []
		for i in range(trainLocations.size()):
			var trainLocation = trainLocations.pop_front()
			var trainIncoming = incomingMap[trainLocation.x][trainLocation.y]
			var trainOutgoing = outgoingMap[trainLocation.x][trainLocation.y]
			var trainType = directionalCellMap[trainLocation.x][trainLocation.y]
			var nextLocation = Global.stepInDirection(trainLocation, trainOutgoing)
			
			if get_cell_atlas_coords(0, nextLocation) == Global.rail_endpoint:
				PLAYSPACE.levelComplete.emit()
			
			#The check for emergencyTrackUsed lets us know if we've already allowed some emergency track laying
			if not emergencyTrackUsed and get_cell_atlas_coords(0, nextLocation) not in Global.rail_tiles:
				useEmergencyRail = true
				Global.cardFunctionStarted.emit()
				#Calling through cardFunctions because that displays the text
				cardFunctions.buildRail(Stats.trainSpeed - stepNumber)
				await rail_built
				Global.cardFunctionEnded.emit()
				trainOutgoing = outgoingMap[trainLocation.x][trainLocation.y]
				nextLocation = Global.stepInDirection(trainLocation, trainOutgoing)
				
				useEmergencyRail = false
				emergencyTrackUsed = true
				
			if get_cell_atlas_coords(0, nextLocation) not in Global.rail_tiles:
				print("TRAIN CRASHED")
				trainCrashed = true
				return
			
			var nextOutgoing = outgoingMap[nextLocation.x][nextLocation.y]
			var nextIncoming = incomingMap[nextLocation.x][nextLocation.y]
			
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
			
			nextTrainLocations.append(nextLocation)
	
		trainLocations = nextTrainLocations
	
	for i in range(trainLocations.size()):
		moveSpriteAlongPoints(trainCars[i], pointsToMoveThrough[i], 0.2)
	
	if turnCounter < map.speedProgression.size()-2:
		turnCounter += 1
		Stats.trainSpeed = map.speedProgression[turnCounter]
		Stats.nextTrainSpeed = map.speedProgression[turnCounter + 1]

func randomTerrainVector():
	var selection = randi_range(0,2)
	if selection == 0:
		return Global.tree
	elif selection == 1:
		return Global.rock
	else:
		return Global.empty

func clearHighlights():
	for cell in highlighted_cells:
		if cell not in locked_highlights:
			set_cell(Global.highlight_layer,cell, 0, Global.delete)
	highlighted_cells.clear()
			
func clearLockedHighlights():
	for cell in locked_highlights:
		if cell not in highlighted_cells:
			set_cell(Global.highlight_layer,cell, 0, Global.delete)
	locked_highlights.clear()
			
			
func screenPositionToMapPosition(screenPosition):
	return local_to_map((screenPosition + fixedElements.position) / scale)
	
func mapPositionToScreenPosition(mapPosition):
	return map_to_local(mapPosition)*scale - fixedElements.position

# Draws the highlight and updates which cells are highlighted
func highlightCells(mousePosition, targetArea:Vector2i, fromTopLeft:bool=false):
	clearHighlights()

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
			and highlighted_tile[0] < fullMapShape[0] \
			and 0 <= highlighted_tile[1] \
			and highlighted_tile[1] < fullMapShape[1]):
				containsOutOfBoundsCell = true
	
	if not containsOutOfBoundsCell:
		highlighted_cells = currently_highlighted_tiles
		drawHighlights(highlighted_cells)

func drawHighlights(highlightedCells):
	for highlightedCell in highlightedCells:
			set_cell(Global.highlight_layer,highlightedCell, 0, Global.highlight)

func buildRail(numRail):
	emit_signal("building_rail")
	originalRailEndpoint = railEndpoint
	originalRevealedTiles = revealedTiles
	if useEmergencyRail and Stats.emergencyRailCount > 0:
		buildingRail = true
		numRailToBuild = min(numRail, Stats.emergencyRailCount)
		highlightCells(get_viewport().get_mouse_position(), Vector2i.ONE)
	elif !useEmergencyRail and Stats.railCount > 0:
		buildingRail = true
		numRailToBuild = min(numRail, Stats.railCount)
		highlightCells(get_viewport().get_mouse_position(), Vector2i.ONE)
	else:
		rail_built.emit(false)

func set_cell_directional(mapPosition, cellType, incoming, outgoing):
	var directional_info = Global.DIRECTIONAL_TILE_INOUT[cellType][incoming][outgoing]
	
	set_cell(0, mapPosition, 0, directional_info[0], directional_info[1])
	directionalCellMap[mapPosition.x][mapPosition.y] = cellType
	incomingMap[mapPosition.x][mapPosition.y] = incoming
	outgoingMap[mapPosition.x][mapPosition.y] = outgoing

func changeOutgoing(mapPosition, direction):
	if mapPosition.x < directionalCellMap.size() \
		and mapPosition.y  < directionalCellMap[0].size() \
		and directionalCellMap[mapPosition.x][mapPosition.y] != null:
			set_cell_directional(mapPosition, directionalCellMap[mapPosition.x][mapPosition.y],
						incomingMap[mapPosition.x][mapPosition.y],
						direction)
			return true
	else:
		return false

func changeIncoming(mapPosition, direction):
	if mapPosition.x < directionalCellMap.size() \
		and mapPosition.y  < directionalCellMap[0].size() \
		and directionalCellMap[mapPosition.x][mapPosition.y] != null:
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
		var amountAdded = addRailLineToMap(railEndpoint, mapPosition, Global.base_layer)
		recalculateRailRoute()
		lastRailPlaced = mapPosition
		numRailToBuild -= amountAdded
		if useEmergencyRail:
			Stats.emergencyRailCount -= amountAdded
		else:
			Stats.railCount -= amountAdded

#Traces rail route to determine which tiles are connected and where the endpoint is
func recalculateRailRoute():
	connectedCells = []
	var currentPosition:Vector2i = railStartpoint
	var prev_outgoing = DIR.U
	while get_cell_atlas_coords(0, currentPosition) in Global.rail_tiles and currentPosition not in connectedCells:
		connectedCells.append(currentPosition)
		changeIncoming(currentPosition, Global.oppositeDir(prev_outgoing))
		prev_outgoing = outgoingMap[currentPosition.x][currentPosition.y]
		railEndpoint = currentPosition
		currentPosition = Global.stepInDirection(currentPosition, outgoingMap[currentPosition.x][currentPosition.y])

func resetPartialRail():
	for rail in partialRailBuilt:
		set_cell(0, rail, 0, Global.empty)
		outgoingMap[rail.x][rail.y] = DIR.NONE
		incomingMap[rail.x][rail.y] = DIR.NONE
		directionalCellMap[rail.x][rail.y] = null
		Stats.railCount += 1
	partialRailBuilt.clear()
	revealedTiles = originalRevealedTiles
	recalculateRailRoute()
	

func toggleRailOutput(mousePosition):
	var clicked_cell = screenPositionToMapPosition(mousePosition)
	if clicked_cell == lastRailPlaced:
		var nextDir = Global.nextDirClockwise(outgoingMap[clicked_cell.x][clicked_cell.y])
		if nextDir == incomingMap[clicked_cell.x][clicked_cell.y]:
			nextDir = Global.nextDirClockwise(nextDir)
			
		changeOutgoing(clicked_cell, nextDir)
	
	recalculateRailRoute()


func drawRailLine(startLoc:Vector2i, endLoc:Vector2i, distance:int):
	directionToStartMap = []
	legalToPlaceRail = false
	if get_cell_atlas_coords(0, endLoc) != Global.empty:
		return
	
	for i in range(fullMapShape.x):
		directionToStartMap.append([])
		for j in range(fullMapShape.y):
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
				if get_cell_atlas_coords(0, nextLoc) == Global.empty and directionToStartMap[nextLoc.x][nextLoc.y] == null:
					directionToStartMap[nextLoc.x][nextLoc.y] = [Global.oppositeDir(dir), steps]
					nextOutermost.append(nextLoc)
				
		outermostLocations = nextOutermost
		
	legalToPlaceRail = directionToStartMap[endLoc.x][endLoc.y] != null
	addRailLineToMap(startLoc, endLoc, Global.temporary_rail_layer)

#Returns amount of rail added
func addRailLineToMap(startLoc, endLoc, layer):
	if get_cell_atlas_coords(0, endLoc) != Global.empty:
		return 0
		
	var directionMap = directionToStartMap.duplicate(true)
	if directionMap[endLoc.x][endLoc.y] == null:
		return 0
	
	var recordTempRail = false
	if layer == Global.base_layer:
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
			
		currentLoc = nextLoc
		
	return (directionMap[endLoc.x][endLoc.y])[1]

func revealFromRail():
	for dir in DIRS:
		var nextCell:Vector2i = Global.stepInDirection(railEndpoint, dir)
		var nextTile = Vector2i(nextCell.x/Global.TILE_SHAPE.x, nextCell.y/Global.TILE_SHAPE.y)
		if nextTile not in revealedTiles:
			revealedTiles.append(nextTile)
			revealTiles()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if buildingRail:
					toggleRailOutput(get_viewport().get_mouse_position())
					if numRailToBuild > 0:
						buildRailOn(get_viewport().get_mouse_position())
						if numRailToBuild == 0:
							clearHighlights()
				
	if event is InputEventMouseMotion:
		clear_layer(Global.temporary_rail_layer)
		if numRailToBuild > 0:
			highlightCells(event.position, Vector2i.ONE)
			drawRailLine(railEndpoint, screenPositionToMapPosition(event.position), numRailToBuild)
		
	if event is InputEventKey and buildingRail:
		clear_layer(Global.temporary_rail_layer)
		if event.key_label == KEY_ESCAPE:
			if event.pressed:
				buildingRail = false
				numRailToBuild = 0
				resetPartialRail()
				rail_built.emit(Global.FUNCTION_STATES.Fail)
		if event.key_label == KEY_ENTER:
			if event.pressed:
				buildingRail = false
				numRailToBuild = 0
				partialRailBuilt.clear()
				revealTiles()
				rail_built.emit(Global.FUNCTION_STATES.Success)
		if event.key_label == KEY_SHIFT:
			buildingRail = false
			numRailToBuild = 0
			resetPartialRail()
			if event.pressed:
				rail_built.emit(Global.FUNCTION_STATES.Shift)
			else:
				rail_built.emit(Global.FUNCTION_STATES.Unshift)
	
	if event is InputEventKey and targeting:
		if event.key_label == KEY_ESCAPE:
			if event.pressed:
				confirmed.emit(Global.FUNCTION_STATES.Fail)
		
		if event.key_label == KEY_ENTER:
			if event.pressed:
				confirmed.emit(Global.FUNCTION_STATES.Success)
				
		if event.key_label == KEY_SHIFT:
			if event.pressed:
				confirmed.emit(Global.FUNCTION_STATES.Shift)
			else:
				confirmed.emit(Global.FUNCTION_STATES.Unshift)
				
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
func _process(delta):
	pass
