class_name Terrain extends TileMap

enum {E, T, M, R, W, L}

signal confirmed(confirmed_or_cancelled)
signal building_rail
signal rail_built(built_or_not)
var buildingRail = false
var numRailToBuild = 0

var targeting = false

var DIRECTION = Global.DIRECTION
var outgoingMap = []
var incomingMap = []
var cellTypeMap = []

const MAP_SIZE = Vector2i(20,10)
var map:MapBase = Corridor.new()

var trainLocations:Array[Vector2i]
var railEndpoint:Vector2i
var originalRailEndpoint:Vector2i
var partialRailBuilt = []

var trainCars = [
	Global.DIRECTIONAL_TILES.TRAIN_FRONT,
	Global.DIRECTIONAL_TILES.TRAIN_MIDDLE,
	Global.DIRECTIONAL_TILES.TRAIN_END,
	]


var trainCrashed = false

@onready var fixedElements = $"../FixedElements"
@onready var highlighted_tiles:Array[Vector2i] = []

var flipH = TileSetAtlasSource.TRANSFORM_FLIP_H
var flipV = TileSetAtlasSource.TRANSFORM_FLIP_V
var transpose = TileSetAtlasSource.TRANSFORM_TRANSPOSE

var in_left_out_down = flipH | transpose
var in_up_out_left = flipH | flipV
var in_right_out_up = transpose | flipV

var in_right_out_down = transpose
var in_down_out_left = flipH
var in_up_out_right = flipV
var in_left_out_up = flipH | flipV | transpose

var in_right_out_left = transpose | flipV
var in_left_out_right = flipH | transpose
var in_up_out_down = flipH | flipV



# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(4):
		add_layer(i)
		set_layer_enabled(i, true)
		set_layer_z_index(i,0)
			
	setUpMap()
	
	fixedElements.position = map_to_local(Vector2(railEndpoint)*scale) - (fixedElements.size /2)*fixedElements.scale
	
	makeMetalShine()

func setUpMap():
	var tiles:Array[Tile] = []
	for tileOptions in map.tiles:
		tileOptions.options.shuffle()
		tiles.append(tileOptions.options[0])
	
	var fullMapShape = Vector2i(map.shape.x*Global.TILE_SHAPE.x, map.shape.y*Global.TILE_SHAPE.y)
	for i in range(fullMapShape.x):
		outgoingMap.append([])
		incomingMap.append([])
		cellTypeMap.append([])
		for j in range(fullMapShape.y + trainCars.size()):
			outgoingMap[i].append(DIRECTION.NONE)
			incomingMap[i].append(DIRECTION.NONE)
			cellTypeMap[i].append(null)
	
	for i in range(map.shape.x):
		for j in range(map.shape.y):
			var tile_cells:Array[Array] = tiles.pop_front().cells
			for x in range(Global.TILE_SHAPE.x):
				for y in range(Global.TILE_SHAPE.y):
					var cellEnum = tile_cells[x][y]
					var cellPosition = Vector2i(j*Global.TILE_SHAPE.y + y, i*Global.TILE_SHAPE.x + x)
					if cellEnum == W:
						set_cell(0,cellPosition, 0, Global.water)
					elif cellEnum == T:
						set_cell(0,cellPosition, 0, Global.tree)
					elif cellEnum == M:
						set_cell(0,cellPosition, 0, Global.rock)
					elif cellEnum == E:
						set_cell(0,cellPosition, 0, Global.empty)
					#TODO: figure out how to handle existing rail
					elif cellEnum == R:
						set_tile_directional(cellPosition, Global.DIRECTIONAL_TILES.RAIL, DIRECTION.DOWN, DIRECTION.UP)
					elif cellEnum == L:
						railEndpoint = cellPosition
						
	for i in range(trainCars.size()):
		set_tile_directional(railEndpoint + Vector2i(0,i), trainCars[i], DIRECTION.DOWN, DIRECTION.UP)
		trainLocations.append(railEndpoint + Vector2i(0,i))

func advanceTrain():
	if trainCrashed: return
	var nextTrainLocations:Array[Vector2i] = []
	for i in range(trainLocations.size()):
		var trainLocation = trainLocations.pop_front()
		var trainIncoming = incomingMap[trainLocation.x][trainLocation.y]
		var trainOutgoing = outgoingMap[trainLocation.x][trainLocation.y]
		var trainType = cellTypeMap[trainLocation.x][trainLocation.y]
		var nextLocation = Vector2i.ZERO
		
		if trainOutgoing == DIRECTION.UP:
			nextLocation = trainLocation + Vector2i(0,-1)
		elif trainOutgoing == DIRECTION.DOWN:
			nextLocation = trainLocation + Vector2i(0,1)
		elif trainOutgoing == DIRECTION.RIGHT:
			nextLocation = trainLocation + Vector2i(1,0)
		else:
			nextLocation = trainLocation + Vector2i(-1,0)
		
		if trainType == Global.DIRECTIONAL_TILES.TRAIN_FRONT and get_cell_atlas_coords(0, nextLocation) not in Global.rail_tiles:
			print("TRAIN CRASHED")
			trainCrashed = true
			return
		
		var nextOutgoing = outgoingMap[nextLocation.x][nextLocation.y]
		var nextIncoming = incomingMap[nextLocation.x][nextLocation.y]
		
		if trainType == Global.DIRECTIONAL_TILES.TRAIN_END:
			set_tile_directional(trainLocation, Global.DIRECTIONAL_TILES.RAIL, trainIncoming, trainOutgoing)
		
		set_tile_directional(nextLocation, trainType, nextIncoming, nextOutgoing)
		nextTrainLocations.append(nextLocation)
		
	
	trainLocations = nextTrainLocations
	

func randomTerrainVector():
	var selection = randi_range(0,2)
	if selection == 0:
		return Global.tree
	elif selection == 1:
		return Global.rock
	else:
		return Global.empty

func clearHighlights():
	highlighted_tiles.clear()
	for i in range(MAP_SIZE[0]):
		for j in range(MAP_SIZE[1]):
			set_cell(Global.highlight_layer,Vector2i(i,j),-1,Vector2i(-1,-1))
			
			
func screenPositionToMapPosition(screenPosition):
	return local_to_map((screenPosition + fixedElements.position) / scale)

# Draws the highlight and updates which cells are highlighted
func highlightCells(mousePosition, targetArea:Vector2i):
	# OPTIMIZE: could just remove the tiles already in highlighted_tiles
	clearHighlights()
	
	var currently_highlighted_tiles:Array[Vector2i] = []
			
	var center_tile = screenPositionToMapPosition(mousePosition)
	currently_highlighted_tiles.append(center_tile)
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
			and highlighted_tile[0] < MAP_SIZE[0] \
			and 0 <= highlighted_tile[1] \
			and highlighted_tile[1] < MAP_SIZE[1]):
				containsOutOfBoundsCell = true
	
	if not containsOutOfBoundsCell:
		highlighted_tiles = currently_highlighted_tiles
		for highlighted_tile in highlighted_tiles:
			set_cell(Global.highlight_layer,highlighted_tile, 0, Global.highlight)

func buildRail(numRail):
	emit_signal("building_rail")
	originalRailEndpoint = railEndpoint
	if Stats.railCount > 0:
		buildingRail = true
		numRailToBuild = min(numRail, Stats.railCount)
		highlightCells(get_viewport().get_mouse_position(), Vector2i.ONE)
	else:
		rail_built.emit(false)

func set_tile_directional(mapPosition, cellType, incoming, outgoing):
	var directional_info = Global.DIRECTIONAL_TILE_INOUT[cellType][incoming][outgoing]
	
	set_cell(0, mapPosition, 0, directional_info[0], directional_info[1])
	cellTypeMap[mapPosition.x][mapPosition.y] = cellType
	incomingMap[mapPosition.x][mapPosition.y] = incoming
	outgoingMap[mapPosition.x][mapPosition.y] = outgoing

func changeOutgoing(mapPosition, direction):
	set_tile_directional(mapPosition, cellTypeMap[mapPosition.x][mapPosition.y],
						incomingMap[mapPosition.x][mapPosition.y],
						direction)

func buildRailOn(mousePosition):
	var mapPosition = screenPositionToMapPosition(mousePosition)
	if get_cell_atlas_coords(0, mapPosition) == Global.empty:
		for adjacent_coords in [Vector2i(1,0), Vector2i(0,1), Vector2i(-1,0), Vector2i(0,-1)]:
			if mapPosition + adjacent_coords == railEndpoint:
				Stats.railCount -= 1
				numRailToBuild -= 1
				var endpointType = cellTypeMap[railEndpoint.x][railEndpoint.y]
				#We are above it
				if adjacent_coords.y == 1:
					set_tile_directional(mapPosition, Global.DIRECTIONAL_TILES.RAIL, DIRECTION.DOWN, DIRECTION.UP)
					changeOutgoing(railEndpoint, DIRECTION.UP)
				#We are below it
				elif adjacent_coords.y == -1:
					set_tile_directional(mapPosition, Global.DIRECTIONAL_TILES.RAIL, DIRECTION.UP, DIRECTION.DOWN)
					changeOutgoing(railEndpoint, DIRECTION.DOWN)
				# We are to the right
				elif adjacent_coords.x == -1:
					set_tile_directional(mapPosition, Global.DIRECTIONAL_TILES.RAIL, DIRECTION.LEFT, DIRECTION.RIGHT)
					changeOutgoing(railEndpoint, DIRECTION.RIGHT)
				# We are to the left
				else:
					set_tile_directional(mapPosition, Global.DIRECTIONAL_TILES.RAIL, DIRECTION.RIGHT, DIRECTION.LEFT)
					changeOutgoing(railEndpoint, DIRECTION.LEFT)
					
				railEndpoint = mapPosition
				partialRailBuilt.append(mapPosition)
	

func resetPartialRail():
	for rail in partialRailBuilt:
		set_cell(0, rail, 0, Global.empty)
		outgoingMap[rail.x][rail.y] = DIRECTION.NONE
		incomingMap[rail.x][rail.y] = DIRECTION.NONE
		Stats.railCount += 1
	partialRailBuilt.clear()
	railEndpoint = originalRailEndpoint
	
func _input(event):
	if event is InputEventMouseButton and numRailToBuild > 0:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				buildRailOn(get_viewport().get_mouse_position())
				if numRailToBuild == 0:
					clearHighlights()
				
	if event is InputEventMouseMotion and numRailToBuild > 0:
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
				
	if event is InputEventMouseButton and targeting and highlighted_tiles.size() > 0:
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
