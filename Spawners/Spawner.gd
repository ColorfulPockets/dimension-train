class_name Spawner extends Sprite2D

@onready var FIXED_ELEMENTS = $"../../FixedElements"
@onready var PLAYSPACE: Playspace = $"../.."

var mouseIn:bool = false
signal mouse_entered
signal mouse_exited

var spawnerName
var enemySpawned

enum FIELDS {TOOLTIP, TYPES, RARITY}

func _init(spawnerName):
	self.spawnerName = spawnerName
	texture = load("res://Assets/Spawners/" + spawnerName + ".png")
	
	match spawnerName:
		"Swamp":
			enemySpawned = "Corrupt Slug"
	
	var tooltip = Tooltip.new("[color=Red]"+spawnerName+": [/color] Spawns [color=Red]" + enemySpawned + "[/color]", 3)
	tooltip.visuals_res = load("res://tooltip.tscn")
	add_child(tooltip)


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
				
