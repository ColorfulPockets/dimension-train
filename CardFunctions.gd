class_name CardFunctions

var tilemap:TileMap = null

func _init(tilemap:TileMap):
	self.tilemap = tilemap

func Chop(highlighted_tiles:Array[Vector2i]):
	for tile in highlighted_tiles:
		if tilemap.get_cell_atlas_coords(0,tile) == Global.tree:
			tilemap.set_cell(0, tile, 0, Global.wood)

func Mine(highlighted_tiles:Array[Vector2i]):
	for tile in highlighted_tiles:
		if tilemap.get_cell_atlas_coords(0,tile) == Global.rock:
			tilemap.set_cell(0, tile, 0, Global.metal)
			
func Transport(highlighted_tiles:Array[Vector2i]):
	for tile in highlighted_tiles:
		if tilemap.get_cell_atlas_coords(0,tile) == Global.wood:
			tilemap.set_cell(0, tile, 0, Global.empty)
		elif tilemap.get_cell_atlas_coords(0,tile) == Global.metal:
			tilemap.set_cell(0, tile, 0, Global.empty)

func Build(highlighted_tiles:Array[Vector2i]):
	for tile in highlighted_tiles:
		pass
