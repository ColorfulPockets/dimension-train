class_name Enemy extends Sprite2D

@onready var FIXED_ELEMENTS = $"../../FixedElements"
@onready var PLAYSPACE = $"../.."
@onready var TERRAIN:Terrain = $".."

var cell:Vector2i
var facing:Global.DIR
var health:int
var healthCounter:HealthCounter
var range = 0

var mouseIn:bool = false
signal mouse_entered
signal mouse_exited

signal drawRangeHighlight(cell, range)
signal clearRangeHighlight

var enemyName: String

const ENEMIES = ["Corrupt Slug"]

static var TOOLTIP_TEXT = {
	"Corrupt Slug": "Moves 1 space forward. Leaves a trail of Corrupted terrain which removes 1 Emergency Rail when harvested.",
	"Guard": "Moves 1 space towards the train, then shoots a projectile dealing 2 damage."
}

func _init(enemyName, cell:Vector2i):
	self.enemyName = enemyName
	self.cell = cell
	self.facing = Global.DIR.L
	texture = load("res://Assets/Enemies/" + enemyName + ".png")
	if enemyName in TOOLTIP_TEXT:
		var tooltip = Tooltip.new("[color=Red]"+enemyName+": [/color]"+TOOLTIP_TEXT[enemyName], 3)
		tooltip.visuals_res = load("res://tooltip.tscn")
		add_child(tooltip)
		
	match enemyName:
		"Corrupt Slug":
			self.facing = randi_range(1,4)
			self.health = 1
		"Guard":
			self.facing = Global.DIR.R
			self.health  = 1
			self.range = 2
	
	match self.facing:
		Global.DIR.L:
			rotation += PI
		Global.DIR.U:
			rotation -= PI/2
		Global.DIR.R:
			pass
		Global.DIR.D:
			rotation += PI/2
	

func initHealthCounter():
	healthCounter = HealthCounter.new()
	healthCounter.text = str(health)
	healthCounter.add_theme_font_size_override("font_size", 100)
	healthCounter.add_theme_constant_override("outline_size", 50)
	healthCounter.add_theme_color_override("font_outline_color", Color.BLACK)
	healthCounter.scale *= 0.1
	healthCounter.position -= healthCounter.size/2
	add_child(healthCounter)

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
			
	return [[]]

func afterMoveActions():
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
				drawRangeHighlight.emit(cell, range)
		else:
			if mouseIn:
				mouseIn = false
				mouse_exited.emit()
				clearRangeHighlight.emit()
				
