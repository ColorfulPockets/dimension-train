class_name Spawner extends Sprite2D

@onready var FIXED_ELEMENTS = $"../../FixedElements"
@onready var PLAYSPACE: Playspace = $"../.."
@onready var TERRAIN: Terrain = $".."

enum INTENT {Spawn, Debuff, Increase}

var mouseIn:bool = false
signal mouse_entered
signal mouse_exited

var previousActions:Array[INTENT] = []
var spawnerName
var spawnerRadius
var enemySpawned
var numSpawned
var counter
# Position on map
var cell

func _init(spawnerName:String, numSpawned:int, cell:Vector2i):
	self.spawnerName = spawnerName
	self.numSpawned = numSpawned
	self.cell = cell
	texture = load("res://Assets/Spawners/" + spawnerName + ".png")
	
	match spawnerName:
		"Swamp":
			enemySpawned = "Corrupt Slug"
			spawnerRadius = 2
	
	var tooltip = Tooltip.new("[color=Red]"+spawnerName+": [/color] Spawns [color=Red]" + enemySpawned + "[/color]", 3)
	tooltip.visuals_res = load("res://tooltip.tscn")
	add_child(tooltip)

func initCounter():
	counter = Label.new()
	counter.text = str(numSpawned)
	counter.add_theme_font_size_override("font_size", 50)
	counter.position = TERRAIN.mapPositionToScreenPosition(cell)
	PLAYSPACE.add_child(counter)

#Called at the start of the turn to add enemies
func startTurnAction():
	pass

#Called at the end of the turn to apply debuffs and self-buff
func endTurnAction():
	pass

func chooseAction() -> INTENT:
	var intent:INTENT = INTENT.Spawn
	match spawnerName:
		"Swamp":
			if previousActions.size() > 2:
				if previousActions[-1] == previousActions[-2]:
					if previousActions[-1] == INTENT.Spawn:
						intent = INTENT.Debuff
					else:
						intent = INTENT.Spawn
			if randi_range(0,1) == 0:
				intent = INTENT.Debuff
			else:
				intent = INTENT.Spawn
	
	previousActions.append(intent)
	return intent
	
func debuff():
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func _input(event):
	if event is InputEventMouseMotion:
		if get_rect().has_point(to_local(event.position + FIXED_ELEMENTS.position)):
			if not mouseIn:
				mouseIn = true
				mouse_entered.emit()
		else:
			if mouseIn:
				mouseIn = false
				mouse_exited.emit()
				
