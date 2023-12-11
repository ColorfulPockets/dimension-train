class_name Terrain extends TileMap

signal confirmed(confirmed_or_cancelled)
signal building_rail
signal rail_built(built_or_not)
var buildingRail = false
var numRailToBuild = 0

var targeting = false

enum FACING {LEFT, RIGHT, UP, DOWN}

const MAP_SIZE = Vector2i(20,10)
var railEndpoint = Vector2i(10,10)
var railEndpointFacing = FACING.UP
var originalRailEndpoint = railEndpoint
var originalRailEndpointFacing = railEndpointFacing
var partialRailBuilt = []

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
	originalRailEndpointFacing = railEndpointFacing
	if Stats.railCount > 0:
		buildingRail = true
		numRailToBuild = min(numRail, Stats.railCount)
		highlightCells(get_viewport().get_mouse_position(), Vector2i.ONE)
	else:
		rail_built.emit(false)

func buildRailOn(mousePosition):
	var mapPosition = screenPositionToMapPosition(mousePosition)
	if get_cell_atlas_coords(0, mapPosition) == Global.empty:
		for adjacent_coords in [Vector2i(1,0), Vector2i(0,1), Vector2i(-1,0), Vector2i(0,-1)]:
			if mapPosition + adjacent_coords == railEndpoint:
				Stats.railCount -= 1
				numRailToBuild -= 1
				#We are above it
				if adjacent_coords.y == 1:
					set_cell(0, mapPosition, 0, Global.rail_straight)
					if railEndpointFacing == FACING.RIGHT:
						set_cell(0, railEndpoint, 0, Global.rail_curve, in_left_out_up)
					elif railEndpointFacing == FACING.LEFT:
						set_cell(0, railEndpoint, 0, Global.rail_curve, in_right_out_up)
					else:
						#Rail is already facing up
						pass
					railEndpointFacing = FACING.UP
				#We are below it
				elif adjacent_coords.y == -1:
					set_cell(0, mapPosition, 0, Global.rail_straight, in_up_out_down)
					if railEndpointFacing == FACING.RIGHT:
						set_cell(0, railEndpoint, 0, Global.rail_curve, in_left_out_down)
					elif railEndpointFacing == FACING.LEFT:
						set_cell(0, railEndpoint, 0, Global.rail_curve, in_right_out_down)
					else:
						#Rail is already facing down
						pass
					railEndpointFacing = FACING.DOWN
				# We are to the right
				elif adjacent_coords.x == -1:
					set_cell(0, mapPosition, 0, Global.rail_straight, in_left_out_right)
					if railEndpointFacing == FACING.UP:
						set_cell(0, railEndpoint, 0, Global.rail_curve)
					elif railEndpointFacing == FACING.DOWN:
						set_cell(0, railEndpoint, 0, Global.rail_curve, in_up_out_right)
					else:
						#Rail is already facing right 
						pass
					railEndpointFacing = FACING.RIGHT
				# We are to the left
				else:
					set_cell(0, mapPosition, 0, Global.rail_straight, in_right_out_left)
					if railEndpointFacing == FACING.UP:
						set_cell(0, railEndpoint, 0, Global.rail_curve, in_down_out_left)
					elif railEndpointFacing == FACING.DOWN:
						set_cell(0, railEndpoint, 0, Global.rail_curve, in_up_out_left)
					else:
						#Rail is already facing right
						pass
					railEndpointFacing = FACING.LEFT
					
				railEndpoint = mapPosition
				partialRailBuilt.append(mapPosition)
	

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
				for rail in partialRailBuilt:
					set_cell(0, rail, 0, Global.empty)
					Stats.railCount += 1
				partialRailBuilt.clear()
				railEndpoint = originalRailEndpoint
				railEndpointFacing = originalRailEndpointFacing
				rail_built.emit(false)
		if event.key_label == KEY_ENTER:
			if event.pressed:
				buildingRail = false
				numRailToBuild = 0
				partialRailBuilt.clear()
				rail_built.emit(true)
	
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
				

# Called when the node enters the scene tree for the first time.
func _ready():
	add_layer(0)
	set_layer_enabled(0, true)
	set_layer_z_index(0,0)
	
	add_layer(1)
	set_layer_enabled(1, true)
	set_layer_z_index(1,0)
	
	add_layer(2)
	set_layer_enabled(2, true)
	set_layer_z_index(2,0)
	
	add_layer(3)
	set_layer_enabled(3, true)
	set_layer_z_index(3,0)
	
	
	for i in range(MAP_SIZE[0]):
		for j in range(MAP_SIZE[1]):
			set_cell(0,Vector2i(i,j),0,randomTerrainVector())
			#set_cell(0,Vector2i(i,j),0,Global.empty)
			
	set_cell(0,railEndpoint,0,Global.rail_straight)
			
	makeMetalShine()

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
