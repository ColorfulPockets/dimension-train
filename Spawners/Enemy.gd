class_name Enemy extends Node2D

@onready var FIXED_ELEMENTS = $"../../FixedElements"
@onready var PLAYSPACE = $"../.."
@onready var TERRAIN:Terrain = $".."

var cell:Vector2i
var facing:Global.DIR
var health:int
var healthCounter:HealthCounter
var range = 0

signal drawRangeHighlight(cell, range)
signal clearRangeHighlight

var enemyName: String

const ENEMIES = ["Corrupt Slug"]

static var TOOLTIP_TEXT = {
	"Corrupt Slug": "Moves 1 space forward. Leaves a trail of Corrupted terrain which removes 1 Emergency Rail when harvested.",
	"Guard": "Moves 1 space towards the train, then shoots a projectile dealing 2 damage."
}

var idleTexture:TextureRect
var moveTexture:TextureRect

func _init(enemyName, cell:Vector2i):
	self.enemyName = enemyName
	self.cell = cell
	self.facing = Global.DIR.L
	
	idleTexture = TextureRect.new()
	moveTexture = TextureRect.new()
	
	idleTexture.texture = load("res://Assets/Enemies/" + enemyName + "/" + enemyName + " Idle.tres")
	moveTexture.texture = load("res://Assets/Enemies/" + enemyName + "/" + enemyName + " Move.tres")
	
	add_child(idleTexture)
	add_child(moveTexture)
	moveTexture.visible = false
	
	idleTexture.position -= idleTexture.texture.get_size()/2
	moveTexture.position -= moveTexture.texture.get_size()/2
	if enemyName in TOOLTIP_TEXT:
		var tooltip = Tooltip.new("[color=Red]"+enemyName+": [/color]"+TOOLTIP_TEXT[enemyName])
		tooltip.visuals_res = load("res://tooltip.tscn")
		idleTexture.add_child(tooltip)
		
	match enemyName:
		"Corrupt Slug":
			self.facing = randi_range(1,4)
			self.health = 1
		"Guard":
			self.facing = Global.DIR.L
			self.health  = 1
			self.range = 1
		"Fire Giant":
			self.facing = [Global.DIR.L, Global.DIR.R].pick_random()
			self.health = 3
	
	updateFacing()

func updateFacing():
	match self.facing:
		Global.DIR.L:
			idleTexture.flip_h = false
			moveTexture.flip_h = false
		Global.DIR.U:
			pass
		Global.DIR.R:
			idleTexture.flip_h = true
			moveTexture.flip_h = true
			#healthCounter.position.x -= idleTexture.size.x*HEALTH_COUNTER_CORNER_X
		Global.DIR.D:
			pass

func initHealthCounter():
	healthCounter = HealthCounter.new()
	healthCounter.text = str(health)
	healthCounter.add_theme_font_size_override("font_size", 100)
	healthCounter.add_theme_constant_override("outline_size", 50)
	healthCounter.add_theme_color_override("font_outline_color", Color.BLACK)
	healthCounter.scale = Vector2(0.1, 0.1)
	add_child(healthCounter)
	healthCounter.position = -healthCounter.scale*healthCounter.size/2
	healthCounter.position += idleTexture.size * 0.25
	healthCounter.position.x += idleTexture.size.x * 0.05

# Currently returns array of pairs: [starting cell, new cell] [starting facing, new facing]
func takeActions() -> Array[Array]:
	var occupied_cells = TERRAIN.getOccupiedCells()
	match enemyName:
		"Corrupt Slug":
			var new_terrain
			var old_cell = cell
			var old_facing = facing
			match TERRAIN.get_cell_atlas_coords(Global.base_layer, cell):
				Global.tree:
					new_terrain = Global.corrupt_tree
				Global.rock:
					new_terrain = Global.corrupt_rock
				_:
					new_terrain = TERRAIN.get_cell_atlas_coords(Global.base_layer, cell)
			
			TERRAIN.set_cell(Global.base_layer, cell, 0, new_terrain)
			
			while cell in occupied_cells:
				var new_cell = Global.stepInDirection(cell, facing)
				# Bounce off edge
				if new_cell.x < 0 or new_cell.y < 0 or new_cell.x >= TERRAIN.mapShape.x or new_cell.y >= TERRAIN.mapShape.y:
					facing = Global.oppositeDir(facing)
					updateFacing()
				cell = Global.stepInDirection(cell, facing)
			
			
			
			return [[old_cell, cell], [old_facing, facing]]
		
		"Guard":
			#########################
			######### MOVE ##########
			#########################
			var getDistance = func(cell1, cell2):
				return sqrt((cell1.x - cell2.x)**2 + (cell1.y - cell2.y)**2)
			var closest_train_cell = Vector2i(INF, INF)
			var minDistance = INF
			var train_locations_copy = TERRAIN.trainLocations.duplicate()
			train_locations_copy.shuffle()
			for location in train_locations_copy:
				var distance = getDistance.call(cell, location)
				if distance < minDistance:
					minDistance = distance
					closest_train_cell = location
			
			var newCell = cell
			var bestDistance = minDistance
#			# Doing this instead of ranges because it randomizes what goes first
			var xVals = [-1,0,1]
			var yVals = [-1,0,1]
			xVals.shuffle()
			yVals.shuffle()
			for x in xVals:
				for y in yVals:
					var potentialNewCell = cell + Vector2i(x,y)
					if potentialNewCell not in occupied_cells and TERRAIN.checkInBounds([potentialNewCell]):
						if getDistance.call(cell + Vector2i(x,y), closest_train_cell) < bestDistance:
							newCell = potentialNewCell
							bestDistance = getDistance.call(cell + Vector2i(x,y), closest_train_cell)
			
			var oldCell = cell
			cell = newCell
			
			return [[oldCell, cell], [facing, facing]]
			
		"Fire Giant":
			var old_cell = cell
			var old_facing = facing
			while cell in occupied_cells:
				var new_cell = Global.stepInDirection(cell, facing)
				# Bounce off edge
				if new_cell.x < 0 or new_cell.y < 0 or new_cell.x >= TERRAIN.mapShape.x or new_cell.y >= TERRAIN.mapShape.y:
					facing = Global.oppositeDir(facing)
					updateFacing()
				cell = Global.stepInDirection(cell, facing)
			return [[old_cell, cell], [old_facing, facing]]
	return [[]]

func afterMoveActions():
	idleTexture.visible = true
	moveTexture.visible = false
	match enemyName:
		"Guard":
			#######################
			###### ATTACK #########
			#######################
			var range_cells = TERRAIN.radiusAroundCell(cell, range)
			for train_cell in TERRAIN.trainLocations:
				if train_cell in range_cells:
					# TODO: add animation
					await TERRAIN.shootProjectile(cell, train_cell)
					Stats.removeEmergencyRail(2)
					break

func startMoving():
	moveTexture.visible = true
	idleTexture.visible = false
	

# Called when the train runs over the enemy
# Collision is true if the train collided with the enemy to kill it
func destroy(collision:bool):
	if collision:
		Stats.removeEmergencyRail(1)
	if "Recycle" in Stats.powersInPlay:
		Stats.addEmergencyRail(2)
		
	clearRangeHighlight.emit()
	
	match enemyName:
		"Corrupt Slug":
			pass
	
	TERRAIN.destroyEnemy(self)

func damage(amount:int):
	self.health -= amount
	if self.health < 1:
		destroy(false)

# Called when the node enters the scene tree for the first time.
func _ready():
	idleTexture.mouse_entered.connect(func():
		drawRangeHighlight.emit(cell, range))
	idleTexture.mouse_exited.connect(func():
		clearRangeHighlight.emit())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

