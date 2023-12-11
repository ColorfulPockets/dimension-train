class_name CardFunctions

var tilemap:Terrain = null

func _init(tilemap:TileMap):
	self.tilemap = tilemap

func Chop(_cardInfo):
	tilemap.targeting = true
	var discard = await tilemap.confirmed
	
	if discard != Global.FUNCTION_STATES.Success:
		return discard
	
	discard = Global.FUNCTION_STATES.Fail
	for tile in tilemap.highlighted_tiles:
		if tilemap.get_cell_atlas_coords(0,tile) == Global.tree:
			tilemap.set_cell(0, tile, 0, Global.wood)
			discard = Global.FUNCTION_STATES.Success
	
	tilemap.targeting = false

	return discard

func Mine(_cardInfo):
	tilemap.targeting = true
	
	var discard = await tilemap.confirmed
	
	if discard != Global.FUNCTION_STATES.Success:
		return discard
		
	discard = Global.FUNCTION_STATES.Fail
	for tile in tilemap.highlighted_tiles:
		if tilemap.get_cell_atlas_coords(0,tile) == Global.rock:
			tilemap.set_cell(0, tile, 0, Global.metal)
			discard = Global.FUNCTION_STATES.Success
	
	tilemap.targeting = false
	
	return discard
			
func Gather(_cardInfo):
	tilemap.targeting = true
	
	var discard = await tilemap.confirmed
	
	if discard != Global.FUNCTION_STATES.Success:
		return discard
		
	discard = Global.FUNCTION_STATES.Fail
	for tile in tilemap.highlighted_tiles:
		if tilemap.get_cell_atlas_coords(0,tile) == Global.wood:
			tilemap.set_cell(0, tile, 0, Global.empty)
			Stats.woodCount += 1
			discard = Global.FUNCTION_STATES.Success
		elif tilemap.get_cell_atlas_coords(0,tile) == Global.metal:
			tilemap.set_cell(0, tile, 0, Global.empty)
			Stats.metalCount += 1
			discard = Global.FUNCTION_STATES.Success
	
	tilemap.targeting = false
	
	return discard

func Build(cardInfo):
	
	var numBuilt = cardInfo[Global.CARD_FIELDS.Arguments][0]
	
	tilemap.buildRail(numBuilt)
	
	var success = await tilemap.rail_built
	
	return Global.FUNCTION_STATES.Success if success else Global.FUNCTION_STATES.Fail
