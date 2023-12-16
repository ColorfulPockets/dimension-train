class_name CardFunctions extends Node

signal confirmed(confirmed)
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
	terrain.buildRail(numBuilt)
	if terrain.useEmergencyRail:
		middleBarContainer.middleBarText.buildingEmergencyRail()
	else:
		middleBarContainer.middleBarText.buildingRail()
	middleBarContainer.visible = true
	middleBarContainer.setPosition(middleBarContainer.POSITIONS.TOP)
	
	var discard = await terrain.rail_built
	
	middleBarContainer.visible = false
	
	return discard
	
func Manufacture(cardInfo):
	terrain.clearHighlights()
	var numManufactured

	numManufactured = cardInfo[Global.CARD_FIELDS.Arguments]["Manufacture"]
	
	middleBarContainer.setText("Manufacture " + str(min(numManufactured, Stats.woodCount*2, Stats.metalCount*2)) + " rails.\n(Enter to confirm, Esc to cancel)")
	middleBarContainer.visible = true
	middleBarContainer.setPosition(middleBarContainer.POSITIONS.TOP)
	
	var confirmed = await confirmed
	
	middleBarContainer.visible = false
	
	if confirmed == Global.FUNCTION_STATES.Success:
		var num_to_manufacture = min(numManufactured, Stats.woodCount*2, Stats.metalCount*2)
		for i in range(int(num_to_manufacture/2)):
			Stats.woodCount -= 1
			Stats.metalCount -= 1
			Stats.railCount += 2
			
	return confirmed
	

func Reveal(cardInfo):
	var numToReveal
	
	numToReveal = cardInfo[Global.CARD_FIELDS.Arguments]["Reveal"]
		
	middleBarContainer.visible = true
	middleBarContainer.setPosition(middleBarContainer.POSITIONS.TOP)
	
	highlight_tiles = true
	var numHighlightedTiles = 0
	
	var selected
	
	while numToReveal > 0:
		middleBarContainer.setText("Reveal "+ str(numToReveal) + " tiles.\n(Esc to cancel)")
		
		selected = await selection
		
		if selected in [Global.FUNCTION_STATES.Shift, Global.FUNCTION_STATES.Unshift, Global.FUNCTION_STATES.Fail]:
			highlight_tiles = false
			terrain.clearHighlights()
			terrain.clearLockedHighlights()
			return selected
		
		if selected == Global.FUNCTION_STATES.Success:
			break
		
		# If we get here, selected is a click
		
		#OPTIMIZE: Making highlighted_cells and locked_highlights dictionaries and using .has() for O(1) key lookup
		for cell in terrain.highlighted_cells:
			if cell not in terrain.locked_highlights:
				terrain.locked_highlights.append(cell)
		
		if terrain.locked_highlights.size() > numHighlightedTiles:	
			numToReveal -= 1
			numHighlightedTiles = terrain.highlighted_cells.size()
		
	highlight_tiles = false
	
	var confirmed
	
	if selected != Global.FUNCTION_STATES.Success:
		confirmed = await confirmed
	else:
		confirmed = Global.FUNCTION_STATES.Success
	
	if confirmed == Global.FUNCTION_STATES.Success:
		for cell in terrain.locked_highlights:
			terrain.set_cell(Global.fog_layer, cell, 0, Global.delete)
	
	terrain.clearLockedHighlights()
	
	middleBarContainer.visible = false
	return confirmed

func _input(event):
	if event is InputEventKey:
		if event.key_label == KEY_ENTER:
			confirmed.emit(Global.FUNCTION_STATES.Success)
			selection.emit(Global.FUNCTION_STATES.Success)
			
		if event.key_label == KEY_ESCAPE:
			confirmed.emit(Global.FUNCTION_STATES.Fail)
			selection.emit(Global.FUNCTION_STATES.Fail)
			
		if event.key_label == KEY_SHIFT:
			if event.pressed:
				confirmed.emit(Global.FUNCTION_STATES.Shift)
				selection.emit(Global.FUNCTION_STATES.Shift)
			else:
				confirmed.emit(Global.FUNCTION_STATES.Unshift)
				selection.emit(Global.FUNCTION_STATES.Unshift)
				
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				selection.emit(null)
				
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
