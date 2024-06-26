extends Label

@onready var terrain:Terrain = $"../../Terrain"

# Called when the node enters the scene tree for the first time.
func _ready():
	terrain.rail_built.connect(func(_x): visible = false, 1)
	terrain.building_rail.connect(func(): visible = true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if visible:
		text = str(terrain.numRailToBuild)
		position = get_viewport().get_mouse_position() + Vector2(64,0)
	
