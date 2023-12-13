class_name CardFunctions extends Node

signal confirmed(confirmed)

@onready var PLAYSPACE:Playspace = $".."
@onready var tilemap:Terrain = $".."/Terrain

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
	
	var discard = await tilemap.rail_built
	
	return discard
	
func Manufacture(cardInfo):
	var numManufactured = cardInfo[Global.CARD_FIELDS.Arguments][0]
	
	var confirmed = await confirmed
	
	if confirmed == Global.FUNCTION_STATES.Success:
		var num_to_manufacture = min(numManufactured, Stats.woodCount, Stats.metalCount)
		for i in range(num_to_manufacture):
			Stats.woodCount -= 1
			Stats.metalCount -= 1
			Stats.railCount += 1
			
	return confirmed
	
func _input(event):
	if event is InputEventKey:
		if event.key_label == KEY_ENTER:
			confirmed.emit(Global.FUNCTION_STATES.Success)
			
		if event.key_label == KEY_ESCAPE:
			confirmed.emit(Global.FUNCTION_STATES.Fail)
			
		if event.key_label == KEY_SHIFT:
			if event.pressed:
				confirmed.emit(Global.FUNCTION_STATES.Shift)
			else:
				confirmed.emit(Global.FUNCTION_STATES.Unshift)
		

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
