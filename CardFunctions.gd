class_name CardFunctions extends Node

signal confirmation(confirmed)
signal selection(selected_or_cancelled)

@onready var PLAYSPACE:Playspace = $".."
@onready var terrain:Terrain = $".."/Terrain
@onready var middleBarContainer:MiddleBarContainer = $".."/FixedElements/MiddleBarContainer

var highlight_tiles = false

func Chop(_cardInfo, displayConfirmation:bool = true):
	var discard
	if displayConfirmation:
		middleBarContainer.visible = true
		middleBarContainer.setPosition(middleBarContainer.POSITIONS.TOP)
		middleBarContainer.setText("Chop Trees\n(Esc to cancel)")
		terrain.targeting = true
		discard = await terrain.confirmed
	
		if discard != Global.FUNCTION_STATES.Success:
			middleBarContainer.visible = false
			return discard
	
	discard = Global.FUNCTION_STATES.Fail

	for tile in terrain.highlighted_cells:
		if terrain.get_cell_atlas_coords(0,tile) == Global.tree:
			terrain.set_cell(0, tile, 0, Global.wood)
			discard = Global.FUNCTION_STATES.Success
		if terrain.get_cell_atlas_coords(0,tile) == Global.corrupt_tree:
			terrain.set_cell(0, tile, 0, Global.wood)
			Stats.removeEmergencyRail(1)
			discard = Global.FUNCTION_STATES.Success
			
	if "Swarm" in Stats.powersInPlay and discard == Global.FUNCTION_STATES.Success:
		var lastHighlightedTargetArea = terrain.lastHighlightedTargetArea
		terrain.pseudoHighlightCells(terrain.lastHighlightedMousePosition, lastHighlightedTargetArea + Vector2i(2,2))
		emptyPseudoHighlighted()
		# Gotta reset the highlight in case something else cares about it
		terrain.highlightCells(terrain.lastHighlightedMousePosition, lastHighlightedTargetArea)
	terrain.targeting = false

	middleBarContainer.visible = false

	return discard

func Mine(_cardInfo, displayConfirmation:bool = true):
	var discard
	if displayConfirmation:
		middleBarContainer.visible = true
		middleBarContainer.setPosition(middleBarContainer.POSITIONS.TOP)
		middleBarContainer.setText("Mine Stone\n(Esc to cancel)")
		
		terrain.targeting = true
		
		discard = await terrain.confirmed
		
		if discard != Global.FUNCTION_STATES.Success:
			middleBarContainer.visible = false
			return discard
		
	discard = Global.FUNCTION_STATES.Fail
	for tile in terrain.highlighted_cells:
		if terrain.get_cell_atlas_coords(0,tile) == Global.rock:
			terrain.set_cell(0, tile, 0, Global.metal)
			discard = Global.FUNCTION_STATES.Success
		if terrain.get_cell_atlas_coords(0,tile) == Global.corrupt_rock:
			terrain.set_cell(0, tile, 0, Global.metal)
			Stats.removeEmergencyRail(1)
			discard = Global.FUNCTION_STATES.Success
	
	if "Swarm" in Stats.powersInPlay and discard == Global.FUNCTION_STATES.Success:
		var lastHighlightedTargetArea = terrain.lastHighlightedTargetArea
		terrain.pseudoHighlightCells(terrain.lastHighlightedMousePosition, lastHighlightedTargetArea + Vector2i(2,2))
		emptyPseudoHighlighted()
		# Gotta reset the highlight in case something else cares about it
		terrain.highlightCells(terrain.lastHighlightedMousePosition, lastHighlightedTargetArea)
	
	terrain.targeting = false
	
	middleBarContainer.visible = false
	return discard

#Replaces all harvestables in pseudohighlighted area with empty tiles
func emptyPseudoHighlighted():
	for tile in terrain.pseudoHighlightedCells:
		if tile not in terrain.highlighted_cells:
			if terrain.get_cell_atlas_coords(0,tile) in Global.harvestable_tiles:
				terrain.set_cell(0, tile, 0, Global.empty)

func Blast(_cardInfo):
	var discard
	middleBarContainer.visible = true
	middleBarContainer.setPosition(middleBarContainer.POSITIONS.TOP)
	middleBarContainer.setText("Chop and Mine\n(Esc to cancel)")
	terrain.targeting = true
	discard = await terrain.confirmed

	if discard != Global.FUNCTION_STATES.Success:
		middleBarContainer.visible = false
		return discard
		
	discard = await Chop(_cardInfo, false)
	
	if discard != Global.FUNCTION_STATES.Success:
		discard = await (Mine(_cardInfo, false))
	else:
		await Mine(_cardInfo, false)
	
	return discard

func Gather(_cardInfo, displayConfirmation=true):
	var discard
	if displayConfirmation:
		middleBarContainer.visible = true
		middleBarContainer.setPosition(middleBarContainer.POSITIONS.TOP)
		middleBarContainer.setText("Gather materials\n(Esc to cancel)")
		
		terrain.targeting = true
		
		discard = await terrain.confirmed
		
		if discard != Global.FUNCTION_STATES.Success:
			middleBarContainer.visible = false
			return discard
		
	discard = Global.FUNCTION_STATES.Fail
	var startingWoodCount = Stats.woodCount
	var startingMetalCount = Stats.metalCount
	for tile in terrain.highlighted_cells:
		if terrain.get_cell_atlas_coords(0,tile) == Global.wood:
			terrain.set_cell(0, tile, 0, Global.empty)
			Stats.woodCount += 1
			discard = Global.FUNCTION_STATES.Success
		elif terrain.get_cell_atlas_coords(0,tile) == Global.metal:
			terrain.set_cell(0, tile, 0, Global.empty)
			Stats.metalCount += 1
			discard = Global.FUNCTION_STATES.Success
	
	if "Fusion Car" in Stats.trainCars:
		if (Stats.woodCount > startingWoodCount) and (Stats.metalCount > startingMetalCount):
			if randi_range(0,1) == 0:
				Stats.woodCount += 1
			else:
				Stats.metalCount += 1
		
	
	terrain.targeting = false
	
	middleBarContainer.visible = false
	return discard

func Build(cardInfo):
	var numBuilt
	
	numBuilt = cardInfo[Global.CARD_FIELDS.Arguments]["Build"]
	
	var buildOver = Global.empty_tiles
	
	if "BuildOver" in cardInfo[Global.CARD_FIELDS.Arguments]:
		buildOver += cardInfo[Global.CARD_FIELDS.Arguments]["BuildOver"]
	
	var discard = await buildRail(numBuilt, buildOver)
	
	return discard

func AutoBuild(_cardInfo):
	if Stats.confirmCardClicks:
		middleBarContainer.setText("Enable Autobuild\n(Enter to confirm, Esc to cancel)")
		middleBarContainer.visible = true
		middleBarContainer.setPosition(middleBarContainer.POSITIONS.TOP)
		
		var confirmed = await confirmation
		
		middleBarContainer.visible = false
		
		if confirmed == Global.FUNCTION_STATES.Success:
			Stats.powersInPlay.append("AutoBuild")
			confirmed = Global.FUNCTION_STATES.Power
			
		return confirmed
	else:
		Stats.powersInPlay.append("AutoBuild")
		return Global.FUNCTION_STATES.Power

# note helper function, not capitalized
func buildRail(numBuilt:int, buildOver:Array):
	if terrain.useEmergencyRail:
		middleBarContainer.middleBarText.buildingEmergencyRail()
	else:
		middleBarContainer.middleBarText.buildingRail()
	middleBarContainer.visible = true
	middleBarContainer.setPosition(middleBarContainer.POSITIONS.TOP)
	
	var discard
	if terrain.buildRail(numBuilt, buildOver):
		discard = await terrain.rail_built
	else:
		discard = Global.FUNCTION_STATES.Fail
	
	middleBarContainer.visible = false
	
	return discard
	
func Manufacture(cardInfo:Dictionary, displayConfirmation:bool = true):
	terrain.clearHighlights()
	var numManufactured
	var confirmed
	
	numManufactured = cardInfo[Global.CARD_FIELDS.Arguments]["Manufacture"]
	
	if displayConfirmation:
		
		middleBarContainer.setText("Manufacture " + str(min(numManufactured, Stats.woodCount*2, Stats.metalCount*2)) + " rails.\n(Enter to confirm, Esc to cancel)")
		middleBarContainer.visible = true
		middleBarContainer.setPosition(middleBarContainer.POSITIONS.TOP)
		
		confirmed = await confirmation
		
		middleBarContainer.visible = false
	
	if confirmed == Global.FUNCTION_STATES.Success or !displayConfirmation:
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
	
	if Stats.trainSpeed <= 0:
		return Global.FUNCTION_STATES.Fail
	
	var amountSlowed

	amountSlowed = cardInfo[Global.CARD_FIELDS.Arguments]["Slow"]
	
	if Stats.confirmCardClicks:
		middleBarContainer.setText("Temporarily reduce train speed to " + str(max(0, Stats.trainSpeed - amountSlowed)) + "\n(Enter to confirm, Esc to cancel)")
		middleBarContainer.visible = true
		middleBarContainer.setPosition(middleBarContainer.POSITIONS.TOP)
		
		var confirmed = await confirmation
		
		middleBarContainer.visible = false
		
		if confirmed == Global.FUNCTION_STATES.Success:
			Stats.trainSpeed = max(0, Stats.trainSpeed - amountSlowed)
			
		return confirmed
	else:
		Stats.trainSpeed = max(0, Stats.trainSpeed - amountSlowed)
		return Global.FUNCTION_STATES.Success

func Gust(cardInfo):
	middleBarContainer.visible = true
	middleBarContainer.setPosition(middleBarContainer.POSITIONS.TOP)
	middleBarContainer.setText("Chop Trees\n(Esc to cancel)")
	terrain.targeting = true
	var discard = await terrain.confirmed
	
	if discard != Global.FUNCTION_STATES.Success:
		middleBarContainer.visible = false
		return discard
	
	Chop(cardInfo, false)
	
	Draw(cardInfo, false)
	
	terrain.targeting = false

	middleBarContainer.visible = false

	return Global.FUNCTION_STATES.Success

func Draw(cardInfo, displayConfirmation:bool = true):
	terrain.clearHighlights()
	
	var amountDrawn

	amountDrawn = cardInfo[Global.CARD_FIELDS.Arguments]["Draw"]
	
	var confirmed = Global.FUNCTION_STATES.Success
	
	if displayConfirmation:
		confirmed = await confirmIfEnabled("Draw " + str(amountDrawn) + " cards.")
	
	if confirmed == Global.FUNCTION_STATES.Success:
		while PLAYSPACE.cardsInHand.size() < PLAYSPACE.HAND_LIMIT - 1 and amountDrawn > 0:
			await PLAYSPACE.drawCardFromDeck()
			amountDrawn -= 1
		
	return confirmed

#Current best template for simple effect
func Brake(cardInfo):
	terrain.clearHighlights()
	
	var amountBraked = cardInfo[Global.CARD_FIELDS.Arguments]["Brake"]
	
	var confirmed = await confirmIfEnabled("Brake " + str(amountBraked))
		
	if confirmed == Global.FUNCTION_STATES.Success:
		Stats.trainSpeed = max(0, Stats.trainSpeed - amountBraked)
		
	return confirmed

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

func Magnet(_cardInfo):
	if Stats.confirmCardClicks:
		middleBarContainer.setText("Increase pickup range to " + str(Stats.pickupRange + 1) + "\n(Enter to confirm, Esc to cancel)")
		middleBarContainer.visible = true
		middleBarContainer.setPosition(middleBarContainer.POSITIONS.TOP)
		
		var confirmed = await confirmation
		
		middleBarContainer.visible = false
		
		if confirmed == Global.FUNCTION_STATES.Success:
			Stats.pickupRange += 1
			Stats.powersInPlay += ["Magnet"]
			confirmed = Global.FUNCTION_STATES.Power
		return confirmed
	
	else:
		Stats.pickupRange += 1
		Stats.powersInPlay += "Magnet"
		return Global.FUNCTION_STATES.Power

func Recycle(_cardInfo):
	terrain.clearHighlights()
	
	var confirmed = await confirmIfEnabled("Recycle enemies for 2 ER")
		
	if confirmed == Global.FUNCTION_STATES.Success:
		Stats.powersInPlay.append("Recycle")
		confirmed = Global.FUNCTION_STATES.Power
		
	return confirmed

func Swarm(_cardInfo):
	terrain.clearHighlights()
	
	var confirmed = await confirmIfEnabled("Clear around Chops and Mines")
		
	if confirmed == Global.FUNCTION_STATES.Success:
		Stats.powersInPlay.append("Swarm")
		confirmed = Global.FUNCTION_STATES.Power
		
	return confirmed

func AutoManufacture(_cardInfo):
	terrain.clearHighlights()
	
	var confirmed = await confirmIfEnabled("AutoManufacture")
		
	if confirmed == Global.FUNCTION_STATES.Success:
		Stats.powersInPlay.append("AutoManufacture")
		confirmed = Global.FUNCTION_STATES.Power
		
	return confirmed

func Turbo(_cardInfo):
	terrain.clearHighlights()
	
	var confirmed = await confirmIfEnabled("Convert all rails to energy")
		
	if confirmed == Global.FUNCTION_STATES.Success:
		Stats.currentEnergy += Stats.railCount
		Stats.railCount = 0
		
	return confirmed

func Bolster(_cardInfo):
	terrain.clearHighlights()
	
	
	var confirmed = await confirmIfEnabled("Bolster a card")
	
	if confirmed == Global.FUNCTION_STATES.Success:
		var bolsterCallback = func():
			for card:CardBase in PLAYSPACE.selectedCards:
				if Global.CARD_FIELDS.TargetArea in card.CardInfo.keys():
					var targetArea = card.CardInfo[Global.CARD_FIELDS.TargetArea]
					targetArea.x += 1
					targetArea.y += 1
					card.CardInfo[Global.CARD_FIELDS.TargetArea] = targetArea
					card.replaceText()
				PLAYSPACE.drawCard(card.position,card.scale,card)
		PLAYSPACE.selectCards(1, bolsterCallback)
	
	return confirmed

func Transmute(_cardInfo):
	middleBarContainer.visible = true
	middleBarContainer.setPosition(middleBarContainer.POSITIONS.TOP)
	middleBarContainer.setText("Transmute Terrain\n(Esc to cancel)")
	
	terrain.targeting = true
	
	var discard = await terrain.confirmed
	
	if discard != Global.FUNCTION_STATES.Success:
		middleBarContainer.visible = false
		return discard
		
	discard = Global.FUNCTION_STATES.Fail
	
	var firstTiles = []
	for i in range(terrain.highlighted_cells.size()):
		var tile = terrain.highlighted_cells[i]
		if terrain.get_cell_atlas_coords(Global.rail_layer,tile) not in Global.rail_tiles:
			firstTiles.append([tile, true])
		else:
			firstTiles.append([tile, false])
		terrain.locked_highlights.append(tile)
	
	firstTiles.sort_custom(
		func(a, b) : 
			var vec1 = a[0]
			var vec2 = b[0]
			if vec1.x < vec2.x: return true
			elif vec1.x > vec2.x: return false
			else: return vec1.y < vec2.y
	)
	terrain.targeting = true
	
	discard  = await terrain.confirmed
	
	if discard != Global.FUNCTION_STATES.Success:
		middleBarContainer.visible = false
		terrain.locked_highlights.clear()
		return discard
	
	# highlighted_cells contains all highlights, including locked, so we have to get rid of those
	# This could be improved by just indexing into the array based on the number of locked highlights
	var secondHighlight = []
	for i in range(terrain.highlighted_cells.size()):
		if terrain.highlighted_cells[i] not in terrain.locked_highlights:
			secondHighlight.append(terrain.highlighted_cells[i])
			
	secondHighlight.sort_custom(
		func(vec1, vec2) : 
			if vec1.x < vec2.x: return true
			elif vec1.x > vec2.x: return false
			else: return vec1.y < vec2.y
	)
	
	for i in range(secondHighlight.size()):
		var secondTile = secondHighlight[i]
		if terrain.get_cell_atlas_coords(Global.rail_layer,secondTile) not in Global.rail_tiles:
			if firstTiles[i][1] != null:
				var firstTileType = terrain.get_cell_atlas_coords(Global.base_layer, firstTiles[i][0])
				terrain.set_cell(Global.base_layer, firstTiles[i][0], 0, terrain.get_cell_atlas_coords(Global.base_layer, secondTile))
				terrain.set_cell(Global.base_layer, secondTile, 0, firstTileType)

	terrain.targeting = false
	
	terrain.highlighted_cells += terrain.locked_highlights
	terrain.locked_highlights.clear()
	terrain.clearHighlights()
	
	middleBarContainer.visible = false
	return discard

func Reforest(cardInfo):
	var discard
	middleBarContainer.visible = true
	middleBarContainer.setPosition(middleBarContainer.POSITIONS.TOP)
	middleBarContainer.setText("Reforest\n(Esc to cancel)")
	terrain.targeting = true
	discard = await terrain.confirmed

	if discard != Global.FUNCTION_STATES.Success:
		middleBarContainer.visible = false
		return discard
	
	for tile in terrain.highlighted_cells:
		if terrain.get_cell_atlas_coords(0,tile) in Global.empty_tiles:
			terrain.set_cell(Global.base_layer, tile, 0, Global.tree)
			
	terrain.targeting = false

	middleBarContainer.visible = false
	
	Draw(cardInfo, false)

	return discard
	
# Best template for effect involving targeting
func Scoop(cardInfo):
	terrain.clearHighlights()
	
	terrain.targeting = true
	
	var confirmed = await confirmTarget("Gather and draw " + str(cardInfo[Global.CARD_FIELDS.Arguments]["Draw"]))
		
	if confirmed == Global.FUNCTION_STATES.Success:
		Gather(cardInfo, false)
		Draw(cardInfo, false)
	
	return confirmed


func confirmIfEnabled(text:String):
	var confirmed
	if Stats.confirmCardClicks:
		confirmed = await middleBarConfirmation(text)
	else:
		confirmed = Global.FUNCTION_STATES.Success
		
	return confirmed

func confirmTarget(text:String):
	middleBarContainer.setText(text + "\n(Esc to cancel)")
	middleBarContainer.visible = true
	middleBarContainer.setPosition(middleBarContainer.POSITIONS.TOP)
	
	var confirmed = await terrain.confirmed
		
	middleBarContainer.visible = false
	return confirmed

func middleBarConfirmation(text:String):
	middleBarContainer.setText(text + "\n(Enter to confirm, Esc to cancel)")
	middleBarContainer.visible = true
	middleBarContainer.setPosition(middleBarContainer.POSITIONS.TOP)
	
	var confirmed = await confirmation
	
	middleBarContainer.visible = false
	
	return confirmed

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
