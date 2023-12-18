extends Node

@onready var overworldScene = $Overworld
var mapScene = null
var loaderThread = Thread.new()
var mapName
var currentLocation = Vector2i(0,0)
const LOAD_TIME = 0.25

# Called when the node enters the scene tree for the first time.
func _ready():
	$Background/Swirl.emitting = true
	overworldScene.map_selected.connect(mapSelected,2)
	overworldScene.drawMap(currentLocation)

func loadMapBackground():
	var map = load("res://Playspace.tscn").instantiate()
	
	call_deferred("fadeInMap")
	
	return map

func fadeInMap():
	var map = loaderThread.wait_to_finish()
	add_child(map)
	map.modulate.a = 0
	map.setMap(mapName)
	
	for i in range(100*LOAD_TIME):
		map.modulate.a += 0.01/LOAD_TIME
		await get_tree().create_timer(0.01).timeout
	
	mapScene = map
	mapScene.levelComplete.connect(returnToOverworld)
	

func mapSelected(mapName, newLocation:Vector2i):
	self.mapName = mapName
	self.currentLocation = newLocation
	loaderThread.start(loadMapBackground)
	
	for i in range(100*LOAD_TIME):
		overworldScene.modulate.a -= 0.01/LOAD_TIME
		await get_tree().create_timer(0.01).timeout
		
	overworldScene.queue_free()
	

func returnToOverworld():
	var overworld = load("res://overworld.tscn").instantiate()
	
	add_child(overworld)
	
	overworldScene = overworld
	
	overworldScene.map_selected.connect(mapSelected,1)
	
	overworldScene.drawMap(currentLocation)
	
	mapScene.queue_free()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
