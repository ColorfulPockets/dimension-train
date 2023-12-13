class_name MiddleBarText extends Label

signal changed()

var building_rail = false
@onready var terrain:Terrain = $"../../../Terrain"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setText(newText):
	text = newText
	changed.emit()

func buildingRail():
	building_rail = true
	
	await terrain.rail_built
	
	building_rail = false
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if building_rail:
		setText("Rail left to build: " + str(terrain.numRailToBuild) + "\n (Enter to confirm, Esc to cancel)")
