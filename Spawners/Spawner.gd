class_name Spawner extends Node2D

@onready var FIXED_ELEMENTS = $"../../FixedElements"
@onready var PLAYSPACE: Playspace = $"../.."
@onready var TERRAIN: Terrain = $".."

enum INTENT {Spawn, Debuff, Increase, Nothing}

signal drawRangeHighlight(cell, offset, range)
signal clearRangeHighlight

var previousActions:Array[INTENT] = []
var spawnerName
var spawnerRadius
var currentDebuff:String
var highlightedCells:Array
var enemySpawned
var numSpawned
# Number of cells to move up or down from the spawner's position, to determine radius
var verticalOffset
var horizontalOffset
var counter
# Position on map
var cell


var debuffDisplay:Debuff
var debuffShowing = false

var increaseDisplay:Debuff
var increaseShowing = false

var textureRect:TextureRect

# Generic counter used in different ways per enemy
var genericCounter = 0


func _init(spawnerName:String, numSpawned:int, cell:Vector2i):
	self.spawnerName = spawnerName
	self.numSpawned = numSpawned
	self.cell = cell
	
	textureRect = TextureRect.new()
	
	textureRect.texture = load("res://Assets/Spawners/" + spawnerName + ".png")
	
	add_child(textureRect)
	
	textureRect.position -= textureRect.texture.get_size()/2
	
	verticalOffset = 0
	horizontalOffset = 0
	match spawnerName:
		"Swamp":
			enemySpawned = "Corrupt Slug"
			spawnerRadius = 2
		"Guard Factory":
			enemySpawned = "Guard"
			spawnerRadius = 2
		"Cave":
			enemySpawned = "Fire Giant"
			spawnerRadius = 1
			verticalOffset = 2
			genericCounter = 1
	
	var getTooltipText = func():
		var text = "[color=Red]"+spawnerName+": [/color] Spawns [color=Red]" + enemySpawned + "[/color]"
		
		if previousActions[-1] == INTENT.Debuff:
			text += "\n\nApplying "+debuffDisplay.process_tooltip()
		if previousActions[-1] == INTENT.Increase:
			text += "\n\nIncreasing number of enemies spawned by 1."
		if previousActions[-1] == INTENT.Spawn:
			text += "\n\nNot taking an action this turn (spawned at start of turn)."
		if previousActions[-1] == INTENT.Nothing:
			text += "\n\nNot taking an action this turn."
		
		return text
	
	var tooltip = Tooltip.new(getTooltipText, true)
	tooltip.visuals_res = load("res://tooltip.tscn")
	textureRect.add_child(tooltip)
	
func initCounter():	
	counter = Label.new()
	counter.text = str(numSpawned)
	counter.add_theme_font_size_override("font_size", 100)
	counter.add_theme_constant_override("outline_size", 50)
	counter.add_theme_color_override("font_outline_color", Color.BLACK)
	counter.scale *= 0.1
	counter.position -= counter.size/2
	add_child(counter)

#Called at the start of the turn to add enemies
func spawnIfSpawning():
	if previousActions[-1] == INTENT.Spawn:
		var cells = highlightedCells.duplicate(true)
		# Remove enemy and spawner locations so we don't overlap
		var occupied_cells = TERRAIN.getEnemyAndSpawnerCells()
		for occupied_cell in occupied_cells:
			if occupied_cell in cells:
				cells.remove_at(cells.find(occupied_cell))
		var i = 0
		while i < numSpawned and cells.size() > 0:
			var chosen_cell = cells.pick_random()
			if chosen_cell in TERRAIN.trainLocations:
				cells.remove_at(cells.find(chosen_cell))
			else:
				TERRAIN.spawnEnemy(enemySpawned, chosen_cell)
				cells.remove_at(cells.find(chosen_cell))
				i += 1

#Called at the end of the turn to apply debuffs and self-buff
func endTurnAction():
	if previousActions[-1] == INTENT.Increase:
		numSpawned += 1
		counter.text = str(numSpawned)
	
	if previousActions[-1] == INTENT.Debuff:
		match spawnerName:
			"Swamp":
				addStackingDebuff("Slimed", 2)
			"Cave":
				if currentDebuff == "Explosion":
					for enemy in TERRAIN.enemies:
						enemy.explode(2)
				elif currentDebuff == "Shaken":
					addStackingDebuff("Shaken", 1)

func addStackingDebuff(debuffName, amount):
	if debuffName in Stats.debuffs.keys():
		Stats.debuffs[debuffName] += amount
	else:
		Stats.debuffs[debuffName] = amount

func spawnDebuff(name, number):
	debuffDisplay = Debuff.new(name, number, true, 0.1)
	debuffDisplay.position -= textureRect.texture.get_size()/4
	debuffDisplay.position -= Vector2(0, textureRect.texture.get_size().y/4)
	debuffShowing = true
	add_child(debuffDisplay)

#Tells Terrain which debuff sprite to spawn
func displayDebuff():
	match spawnerName:
		"Swamp":
			spawnDebuff("Slimed", 2)
		"Cave":
			if currentDebuff == "Explosion":
				spawnDebuff(currentDebuff, 0)
			elif currentDebuff == "Shaken":
				spawnDebuff(currentDebuff, 1)
				

func clearDebuffDisplay():
	if debuffShowing:
		debuffDisplay.queue_free()
		debuffShowing = false
		
func displayIncrease():
	increaseDisplay = Debuff.new("Increase", 1, true, 0.125)
	increaseDisplay.position -= textureRect.texture.get_size()/2
	increaseDisplay.position.x += 8
	increaseDisplay.position -= Vector2(0, textureRect.texture.get_size().y/4)
	increaseShowing = true
	add_child(increaseDisplay)


func clearIncreaseDisplay():
	if increaseShowing:
		increaseDisplay.queue_free()
		increaseShowing = false


#Logic for spawner patterns
func chooseAction():
	var intent:INTENT = INTENT.Spawn
	match spawnerName:
		"Swamp":
			# Can't do the same thing 3 times in a row
			if previousActions.size() >= 2:
				if previousActions[-1] == previousActions[-2]:
					if previousActions[-1] == INTENT.Spawn:
						intent = INTENT.Debuff
					else:
						intent = INTENT.Spawn
			elif randi_range(0,1) == 0:
				intent = INTENT.Debuff
			else:
				intent = INTENT.Spawn
		"Guard Factory":
			if randi_range(0,2) == 0:
				intent = INTENT.Increase
			else:
				intent = INTENT.Spawn
		"Cave":
			if TERRAIN.enemies.size() == 0:
				if genericCounter > 0:
					intent = INTENT.Spawn
					genericCounter = 0
				else:
					intent = INTENT.Nothing
					genericCounter += 1
			else:
				intent = INTENT.Debuff
				if randi_range(0, 1) == 0:
					currentDebuff = "Explosion"
				else:
					currentDebuff = "Shaken"
	
	if intent == INTENT.Debuff:
		clearDebuffDisplay()
		displayDebuff()
		clearIncreaseDisplay()
	elif intent == INTENT.Increase:
		displayIncrease()
		clearDebuffDisplay()
	else:
		clearDebuffDisplay()
		clearIncreaseDisplay()
	previousActions.append(intent)
	

# Called when the node enters the scene tree for the first time.
func _ready():
	textureRect.mouse_entered.connect(func():
		drawRangeHighlight.emit(cell, Vector2i(horizontalOffset, verticalOffset), spawnerRadius))
	textureRect.mouse_exited.connect(func():
		clearRangeHighlight.emit())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

