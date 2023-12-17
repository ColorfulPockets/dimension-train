class_name Terrain extends TileMap

enum {E, T, M, R, W, L, G}

signal confirmed(confirmed_or_cancelled)
signal building_rail
signal rail_built(built_or_not)
var buildingRail = false
var numRailToBuild = 0

var targeting = false

var DIR = Global.DIR
var outgoingMap = []
var incomingMap = []
var directionalCellMap = []
var connectedCells:Array[Vector2i] = []

var fullMapShape:Vector2i = Vector2i(0,0)
var revealedTiles:Array[Vector2i] = []
var originalRevealedTiles
var map:MapBase = Corridor.new()
var turnCounter = 0

var trainLocations:Array[Vector2i]
var railEndpoint:Vector2i
var originalRailEndpoint:Vector2i
var partialRailBuilt:Array[Vector2i] = []

var useEmergencyRail = false

var trainCars = [
	Global.DIRECTIONAL_TILES.TRAIN_FRONT,
	Global.DIRECTIONAL_TILES.TRAIN_MIDDLE,
	Global.DIRECTIONAL_TILES.TRAIN_END,
	]


var trainCrashed = false

@onready var fixedElements = $"../FixedElements"
@onready var cardFunctions = $"../CardFunctions"

var highlighted_cells:Array[Vector2i] = []
var locked_highlights:Array[Vector2i] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(5):
		add_layer(i)
		set_layer_enabled(i, true)
		set_layer_z_index(i,0)
			
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
					elif cellEnum == G:
						set_cell_directional(cellPosition, Global.DIRECTIONAL_TILES.RAIL_END, cellDirections[0], cellDirections[1])
						
	for i:int in range(fullMapShape.x):
		for j:int in range(fullMapShape.y):
			#Cover in fog
			set_cell(Global.fog_layer, Vector2i(i,j), 0, Global.fog)
			
	revealedTiles.append(map.startTile)
	revealTiles()
	
	for i in range(trainCars.size()):
		set_cell_directional(railEndpoint + Vector2i(0,i), trainCars[i], DIR.D, DIR.U)
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
						

func advanceTrain():
	if trainCrashed: return
	
	var emergencyTrackUsed = false
	for stepNumber in range(Stats.trainSpeed):
		var nextTrainLocations:Array[Vector2i] = []
		for i in range(trainLocations.size()):
			var trainLocation = trainLocations.pop_front()
			var trainIncoming = incomingMap[trainLocation.x][trainLocation.y]
			var trainOutgoing = outgoingMap[trainLocation.x][trainLocation.y]
			var trainType = directionalCellMap[trainLocation.x][trainLocation.y]
			var nextLocation = Vector2i.ZERO
			
			if trainOutgoing == DIR.U:
				nextLocation = trainLocation + Vector2i(0,-1)
			elif trainOutgoing == DIR.D:
				nextLocation = trainLocation + Vector2i(0,1)
			elif trainOutgoing == DIR.R:
				nextLocation = trainLocation + Vector2i(1,0)
			else:
				nextLocation = trainLocation + Vector2i(-1,0)
			
			if trainType == Global.DIRECTIONAL_TILES.TRAIN_FRONT and get_cell_atlas_coords(0, nextLocation) == Global.rail_endpoint:
				print("LEVEL COMPLETE")
			
			#The check for emergencyTrackUsed lets us know if we've already allowed some emergency track laying
			if not emergencyTrackUsed and trainType == Global.DIRECTIONAL_TILES.TRAIN_FRONT and get_cell_atlas_coords(0, nextLocation) not in Global.rail_tiles:
				useEmergencyRail = true
				Global.cardFunctionStarted.emit()
				#Calling through cardFunctions because that displays the text
				cardFunctions.buildRail(Stats.trainSpeed - stepNumber)
				await rail_built
				Global.cardFunctionEnded.emit()
				trainOutgoing = outgoingMap[trainLocation.x][trainLocation.y]
				if trainOutgoing == DIR.U:
					nextLocation = trainLocation + Vector2i(0,-1)
				elif trainOutgoing == DIR.D:
					nextLocation = trainLocation + Vector2i(0,1)
				elif trainOutgoing == DIR.R:
					nextLocation = trainLocation + Vector2i(1,0)
				else:
					nextLocation = trainLocation + Vector2i(-1,0)
				
				useEmergencyRail = false
				emergencyTrackUsed = true
				
			if trainType == Global.DIRECTIONAL_TILES.TRAIN_FRONT and get_cell_atlas_coords(0, nextLocation) not in Global.rail_tiles:
				print("TRAIN CRASHED")
				trainCrashed = true
				return
			
			var nextOutgoing = outgoingMap[nextLocation.x][nextLocation.y]
			var nextIncoming = incomingMap[nextLocation.x][nextLocation.y]
			
			if trainType == Global.DIRECTIONAL_TILES.TRAIN_END:
				set_cell_directional(trainLocation, Global.DIRECTIONAL_TILES.RAIL, trainIncoming, trainOutgoing)
			
			set_cell_directional(nextLocation, trainType, nextIncoming, nextOutgoing)
			nextTrainLocations.append(nextLocation)
		await get_tree().create_timer(Global.TRAIN_MOVEMENT_TIME).timeout
	
		trainLocations = nextTrainLocations
	
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
	var mapPosition:Vector2i = screenPositionToMapPosition(mousePosition)
	if get_cell_atlas_coords(0, mapPosition) == Global.empty and get_cell_atlas_coords(Global.fog_layer, mapPosition) != Global.fog:
		for adjacent_coords in [Vector2i(1,0), Vector2i(0,1), Vector2i(-1,0), Vector2i(0,-1)]:
			if mapPosition + adjacent_coords == railEndpoint:
				if useEmergencyRail:
					Stats.emergencyRailCount -= 1
				else:
					Stats.railCount -= 1
				numRailToBuild -= 1
				connectedCells.append(mapPosition)
				#We are above it
				if adjacent_coords.y == 1:
					set_cell_directional(mapPosition, Global.DIRECTIONAL_TILES.RAIL, DIR.D, DIR.U)
					changeOutgoing(railEndpoint, DIR.U)
					if not (get_tile(mapPosition + Vector2i(0,-1)) in revealedTiles):
						revealedTiles.append(get_tile(mapPosition + Vector2i(0,-1)))
				#We are below it
				elif adjacent_coords.y == -1:
					set_cell_directional(mapPosition, Global.DIRECTIONAL_TILES.RAIL, DIR.U, DIR.D)
					changeOutgoing(railEndpoint, DIR.D)
					if not (get_tile(mapPosition + Vector2i(0,1)) in revealedTiles):
						revealedTiles.append(get_tile(mapPosition + Vector2i(0,1)))
				# We are to the right
				elif adjacent_coords.x == -1:
					set_cell_directional(mapPosition, Global.DIRECTIONAL_TILES.RAIL, DIR.L, DIR.R)
					changeOutgoing(railEndpoint, DIR.R)
					if not (get_tile(mapPosition + Vector2i(1,0)) in revealedTiles):
						revealedTiles.append(get_tile(mapPosition + Vector2i(1,0)))
				# We are to the left
				else:
					set_cell_directional(mapPosition, Global.DIRECTIONAL_TILES.RAIL, DIR.R, DIR.L)
					changeOutgoing(railEndpoint, DIR.L)
					if not (get_tile(mapPosition + Vector2i(-1,0)) in revealedTiles):
						revealedTiles.append(get_tile(mapPosition + Vector2i(-1,0)))
				
				for pair in [[Vector2i(1,0), DIR.L], [Vector2i(-1,0), DIR.R],[Vector2i(0,-1), DIR.D], [Vector2i(0,1), DIR.U]]:
					if mapPosition + pair[0] not in connectedCells:
						if changeIncoming(mapPosition + pair[0], pair[1]):
							changeOutgoing(mapPosition, Global.oppositeDir(pair[1]))
							connectedCells.append(mapPosition + pair[0])
					
				railEndpoint = mapPosition
				partialRailBuilt.append(mapPosition)
	

func resetPartialRail():
	for rail in partialRailBuilt:
		set_cell(0, rail, 0, Global.empty)
		outgoingMap[rail.x][rail.y] = DIR.NONE
		incomingMap[rail.x][rail.y] = DIR.NONE
		Stats.railCount += 1
	partialRailBuilt.clear()
	railEndpoint = originalRailEndpoint
	revealedTiles = originalRevealedTiles
	
func _input(event):
	if event is InputEventMouseButton and numRailToBuild > 0:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				buildRailOn(get_viewport().get_mouse_position())
				if numRailToBuild == 0:
					clearHighlights()
				
	if event is InputEventMouseMotion:
		if numRailToBuild > 0:
			highlightCells(event.position, Vector2i.ONE)
		
	if event is InputEventKey and buildingRail:
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
