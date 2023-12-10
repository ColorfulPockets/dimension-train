extends TileMap

const MAP_SIZE = Vector2i(20,10)

@onready var fixedElements = $"../FixedElements"
@onready var highlighted_tiles:Array[Vector2i] = []

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
	
	
	for i in range(MAP_SIZE[0]):
		for j in range(MAP_SIZE[1]):
			set_cell(0,Vector2i(i,j),0,randomTerrainVector())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
		
