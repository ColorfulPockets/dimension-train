extends TileMap

var tree = Vector2i(4,2)
var rock = Vector2i(0,3)
var empty = Vector2i(0,0)
var highlight = Vector2i(2,4)
const MAP_SIZE = Vector2i(20,10)

var highlightRegion = PackedVector2Array()

@onready var fixedElements = $"../FixedElements"

func randomTerrainVector():
	var selection = randi_range(0,2)
	if selection == 0:
		return tree
	elif selection == 1:
		return rock
	else:
		return empty

func clearHighlights():
	for i in range(MAP_SIZE[0]):
		for j in range(MAP_SIZE[1]):
			set_cell(1,Vector2i(i,j),-1,Vector2i(-1,-1))
			
			
func screenPositionToMapPosition(screenPosition):
	return local_to_map((screenPosition + fixedElements.position) / scale)

func highlightCells(mousePosition, targetArea:Vector2i):
	for i in range(MAP_SIZE[0]):
		for j in range(MAP_SIZE[1]):
			set_cell(1,Vector2i(i,j),-1,Vector2i(-1,-1))
			
	var highlighted_tiles = []
	var center_tile = screenPositionToMapPosition(mousePosition)
	highlighted_tiles.append(center_tile)
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
			highlighted_tiles.append(screenPositionToMapPosition(
				mousePosition + Vector2(
					(addX + i)*tile_set.tile_size.x*scale.x, 
					(addY + j)*tile_set.tile_size.y*scale.y)))
			highlighted_tiles.append(screenPositionToMapPosition(
				mousePosition + Vector2(
					-1*(addX + i)*tile_set.tile_size.x*scale.x, 
					(addY + j)*tile_set.tile_size.y*scale.y)))
			highlighted_tiles.append(screenPositionToMapPosition(
				mousePosition + Vector2(
					-1*(addX + i)*tile_set.tile_size.x*scale.x, 
					-1*(addY + j)*tile_set.tile_size.y*scale.y)))
			highlighted_tiles.append(screenPositionToMapPosition(
				mousePosition + Vector2(
					(addX + i)*tile_set.tile_size.x*scale.x, 
					-1*(addY + j)*tile_set.tile_size.y*scale.y)))
					
	for highlighted_tile in highlighted_tiles:
		if 0 <= highlighted_tile[0] \
			and highlighted_tile[0] < MAP_SIZE[0] \
			and 0 <= highlighted_tile[1] \
			and highlighted_tile[1] < MAP_SIZE[1]:
			set_cell(1,highlighted_tile, 0, highlight)

# Called when the node enters the scene tree for the first time.
func _ready():
	add_layer(0)
	set_layer_enabled(0, true)
	set_layer_name(0, "base")
	set_layer_z_index(0,0)
	
	add_layer(1)
	set_layer_enabled(1, true)
	set_layer_name(1, "highlight")
	set_layer_z_index(1,0)
	
	for i in range(MAP_SIZE[0]):
		for j in range(MAP_SIZE[1]):
			set_cell(0,Vector2i(i,j),0,randomTerrainVector())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
		
