extends Node

@onready var currentScene = $Overworld

# Called when the node enters the scene tree for the first time.
func _ready():
	$Background/Swirl.emitting = true
	currentScene.map_selected.connect(mapSelected,1)

func mapSelected(mapName):
	var map = load("res://Playspace.tscn").instantiate()

	add_child(map)
	var background = $Background
	remove_child(background)
	var fixedElements = get_node("Playspace/FixedElements")
	fixedElements.add_child(background)
	map.setMap(mapName)
	currentScene.queue_free()
	currentScene = map

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
