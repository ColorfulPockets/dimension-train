class_name CardFunctions extends Node

signal confirmation(confirmed)
signal selection(selected_or_cancelled)

@onready var PLAYSPACE:Playspace = $".."
@onready var terrain:Terrain = $".."/Terrain
@onready var middleBarContainer:MiddleBarContainer = $".."/FixedElements/MiddleBarContainer

var highlight_tiles = false

func Chop(_cardInfo):
	middleBarContainer.visible = true
	middleBarContainer.setPosition(middleBarContainer.POSITIONS.TOP)
	middleBarContainer.setText("Chop Trees\n(Esc to cancel)")
	terrain.targeting = true
	var discard = await terrain.confirmed
	
	if discard != Global.FUNCTION_STATES.Success:
		middleBarContainer.visible = false
		return discard
	
	discard = Global.FUNCTION_STATES.Fail
	for tile in terrain.highlighted_cells:
		if terrain.get_cell_atlas_coords(0,tile) == Global.tree:
			terrain.set_cell(0, tile, 0, Global.wood)
			discard = Global.FUNCTION_STATES.Success
	
	terrain.targeting = false

	middleBarContainer.visible = false

	return discard

func Mine(_cardInfo):
	middleBarContainer.visible = true
	middleBarContainer.setPosition(middleBarContainer.POSITIONS.TOP)
	middleBarContainer.setText("Mine Stone\n(Esc to cancel)")
	
	terrain.targeting = true
	
	var discard = await terrain.confirmed
	
	if discard != Global.FUNCTION_STATES.Success:
		middleBarContainer.visible = false
		return discard
		
	discard = Global.FUNCTION_STATES.Fail
	for tile in terrain.highlighted_cells:
		if terrain.get_cell_atlas_coords(0,tile) == Global.rock:
			terrain.set_cell(0, tile, 0, Global.metal)
			discard = Global.FUNCTION_STATES.Success
	
	terrain.targeting = false
	
	middleBarContainer.visible = false
	return discard
			
func Gather(_cardInfo):
	middleBarContainer.visible = true
	middleBarContainer.setPosition(middleBarContainer.POSITIONS.TOP)
	middleBarContainer.setText("Gather materials\n(Esc to cancel)")
	
	terrain.targeting = true
	
	var discard = await terrain.confirmed
	
	if discard != Global.FUNCTION_STATES.Success:
		middleBarContainer.visible = false
		return discard
		
	discard = Global.FUNCTION_STATES.Fail
	for tile in terrain.highlighted_cells:
		if terrain.get_cell_atlas_coords(0,tile) == Global.wood:
			terrain.set_cell(0, tile, 0, Global.empty)
			Stats.woodCount += 1
			discard = Global.FUNCTION_STATES.Success
		elif terrain.get_cell_atlas_coords(0,tile) == Global.metal:
			terrain.set_cell(0, tile, 0, Global.empty)
			Stats.metalCount += 1
			discard = Global.FUNCTION_STATES.Success
	
	terrain.targeting = false
	
	middleBarContainer.visible = false
	return discard

func Build(cardInfo):
	var numBuilt
	
	numBuilt = cardInfo[Global.CARD_FIELDS.Arguments]["Build"]
	
	var discard = await buildRail(numBuilt)
	
	return discard

# note helper function, not capitalized
func buildRail(numBuilt):
	if terrain.useEmergencyRail:
		middleBarContainer.middleBarText.buildingEmergencyRail()
	else:
		middleBarContainer.middleBarText.buildingRail()
	middleBarContainer.visible = true
	middleBarContainer.setPosition(middleBarContainer.POSITIONS.TOP)
	
	var discard
	if terrain.buildRail(numBuilt):
		discard = await terrain.rail_built
	else:
		discard = Global.FUNCTION_STATES.Fail
	
	middleBarContainer.visible = false
	
	return discard
	
func Manufacture(cardInfo):
	terrain.clearHighlights()
	var numManufactured

	numManufactured = cardInfo[Global.CARD_FIELDS.Arguments]["Manufacture"]
	
	middleBarContainer.setText("Manufacture " + str(min(numManufactured, Stats.woodCount*2, Stats.metalCount*2)) + " rails.\n(Enter to confirm, Esc to cancel)")
	middleBarContainer.visible = true
	middleBarContainer.setPosition(middleBarContainer.POSITIONS.TOP)
	
	var confirmed = await confirmation
	
	middleBarContainer.visible = false
	
	if confirmed == Global.FUNCTION_STATES.Success:
		var num_to_manufacture = min(numManufactured, Stats.woodCount*2, Stats.metalCount*2)
		for i in range(int(num_to_manufacture/2)):
			Stats.woodCount -= 1
			Stats.metalCount -= 1
			Stats.railCount += 2
			
	return confirmed

func Factory(cardInfo):
	middleBarContainer.visible = true
	middleBarContainer.setPosition(middleBarContainer.POSITIONS.TOP)
	middleBarContainer.setText("Gather materials\n(Esc to cancel)")
	
	terrain.targeting = true
	
	var discard = await terrain.confirmed
	
	if discard != Global.FUNCTION_STATES.Success:
		middleBarContainer.visible = false
		return discard
		
	var harvested_wood = []
	var harvested_metal = []
	for tile in terrain.highlighted_cells:
		if terrain.get_cell_atlas_coords(0,tile) == Global.wood:
			harvested_wood.append(tile)
			terrain.set_cell(0, tile, 0, Global.empty)
			Stats.woodCount += 1
		elif terrain.get_cell_atlas_coords(0,tile) == Global.metal:
			harvested_metal.append(tile)
			terrain.set_cell(0, tile, 0, Global.empty)
			Stats.metalCount += 1
	
	terrain.targeting = false
	
	middleBarContainer.visible = false
	
	# Manufacture
	terrain.clearHighlights()
	var numManufactured

	numManufactured = cardInfo[Global.CARD_FIELDS.Arguments]["Manufacture"]
	
	middleBarContainer.setText("Manufacture " + str(min(numManufactured, Stats.woodCount*2, Stats.metalCount*2)) + " rails.\n(Enter to confirm, Esc to cancel)")
	middleBarContainer.visible = true
	middleBarContainer.setPosition(middleBarContainer.POSITIONS.TOP)
	
	var confirmed = await confirmation
	
	middleBarContainer.visible = false
	
	if confirmed == Global.FUNCTION_STATES.Success:
		var num_to_manufacture = min(numManufactured, Stats.woodCount*2, Stats.metalCount*2)
		for i in range(int(num_to_manufacture/2)):
			Stats.woodCount -= 1
			Stats.metalCount -= 1
			Stats.railCount += 2
	else:
		for tile in harvested_wood:
			terrain.set_cell(0, tile, 0, Global.wood)
			Stats.woodCount -= 1
		for tile in harvested_metal:
			terrain.set_cell(0, tile, 0, Global.metal)
			Stats.metalCount += 1
			
	return confirmed

func Slow(cardInfo):
	terrain.clearHighlights()
	
	var amountSlowed

	amountSlowed = cardInfo[Global.CARD_FIELDS.Arguments]["Slow"]
	
	middleBarContainer.setText("Temporarily reduce train speed to " + str(max(0, Stats.trainSpeed - amountSlowed)) + "\n(Enter to confirm, Esc to cancel)")
	middleBarContainer.visible = true
	middleBarContainer.setPosition(middleBarContainer.POSITIONS.TOP)
	
	var confirmed = await confirmation
	
	middleBarContainer.visible = false
	
	if confirmed == Global.FUNCTION_STATES.Success:
		Stats.trainSpeed = max(0, Stats.trainSpeed - amountSlowed)
		
	return confirmed

func Gust(cardInfo):
	middleBarContainer.visible = true
	middleBarContainer.setPosition(middleBarContainer.POSITIONS.TOP)
	middleBarContainer.setText("Chop Trees\n(Esc to cancel)")
	terrain.targeting = true
	var discard = await terrain.confirmed
	
	if discard != Global.FUNCTION_STATES.Success:
		middleBarContainer.visible = false
		return discard
	
	for tile in terrain.highlighted_cells:
		if terrain.get_cell_atlas_coords(0,tile) == Global.tree:
			terrain.set_cell(0, tile, 0, Global.wood)
	
	Draw(cardInfo)
	
	terrain.targeting = false

	middleBarContainer.visible = false

	return Global.FUNCTION_STATES.Success

func Draw(cardInfo):
	terrain.clearHighlights()
	
	var amountDrawn

	amountDrawn = cardInfo[Global.CARD_FIELDS.Arguments]["Draw"]
	
	while PLAYSPACE.cardsInHand.size() < PLAYSPACE.HAND_LIMIT - 1 and amountDrawn > 0:
		await PLAYSPACE.drawCardFromDeck()
		amountDrawn -= 1
	
	return Global.FUNCTION_STATES.Success

func Bridge(_cardInfo):
	middleBarContainer.visible = true
	middleBarContainer.setPosition(middleBarContainer.POSITIONS.TOP)
	middleBarContainer.setText("Bridge over water\n(Esc to cancel)")
	
	terrain.targeting = true
	
	var discard = await terrain.confirmed
	
	if discard != Global.FUNCTION_STATES.Success:
		middleBarContainer.visible = false
		return discard
		
	discard = Global.FUNCTION_STATES.Fail
	for tile in terrain.highlighted_cells:
		if terrain.get_cell_atlas_coords(0,tile) == Global.water:
			terrain.set_cell(0, tile, 0, Global.bridge)
			discard = Global.FUNCTION_STATES.Success
		
	terrain.targeting = false
	
	middleBarContainer.visible = false
	return discard

func _input(event):
	if event is InputEventKey:
		if event.key_label == KEY_ENTER:
			confirmation.emit(Global.FUNCTION_STATES.Success)
			selection.emit(Global.FUNCTION_STATES.Success)
			
		if event.key_label == KEY_ESCAPE:
			confirmation.emit(Global.FUNCTION_STATES.Fail)
			selection.emit(Global.FUNCTION_STATES.Fail)
				
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				selection.emit(-1)
				
	if event is InputEventMouseMotion:
		if highlight_tiles:
			var eventMapPosition = terrain.screenPositionToMapPosition(event.position)
			var tile_corner  = Global.TILE_SHAPE * Vector2i(eventMapPosition.x / Global.TILE_SHAPE.x, eventMapPosition.y / Global.TILE_SHAPE.y)
			terrain.highlightCells(terrain.mapPositionToScreenPosition(tile_corner), Global.TILE_SHAPE, true)
		

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
