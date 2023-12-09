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
			
func highlightCells(mousePosition):
	for i in range(MAP_SIZE[0]):
		for j in range(MAP_SIZE[1]):
			set_cell(1,Vector2i(i,j),-1,Vector2i(-1,-1))
			
	var highlighted_tile = local_to_map((mousePosition + fixedElements.position) / scale)
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
		
