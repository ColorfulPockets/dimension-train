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

var enemyName: String

const ENEMIES = ["Corrupt Slug"]

static var TOOLTIP_TEXT = {
	"Corrupt Slug": "Moves 1 space forward. Leaves a trail of Corrupted terrain which removes 1 Emergency Rail when harvested.",
	"Guard": "Moves 1 space towards the train, then shoots a projectile dealing 1 damage."
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
			var closest_train_cell = Vector2i(INF, INF)
			var minDistance = INF
			var train_locations_copy = TERRAIN.trainLocations.duplicate()
			train_locations_copy.shuffle()
			for location in train_locations_copy:
				var distance = min(abs(cell.x-location.x), abs(cell.y-location.y))
				if distance < minDistance:
					minDistance = distance
					closest_train_cell = location

			var oldCell = cell
			var newCell = cell
			var xChanged = false
			var yChanged = false
			if closest_train_cell.x > cell.x:
				newCell.x += 1
				xChanged = true
			elif closest_train_cell.x < cell.x:
				newCell.x -= 1
				xChanged = true
			
			if closest_train_cell.y > cell.y:
				newCell.y += 1
				yChanged = true
			elif closest_train_cell.y < cell.y:
				newCell.y -= 1
				yChanged = true
			
			while newCell in occupied_cells and newCell != cell:
				#randomize which direction to try to adjust
				if randi_range(0,1) == 0:
					if xChanged:
						newCell.x = cell.x
					elif yChanged:
						newCell.y = cell.y
				else:
					if yChanged:
						newCell.y = cell.y
					elif xChanged:
						newCell.x = cell.x
			
			cell = newCell
			
			return [[oldCell, cell], [facing, facing]]
			
	return [[]]

# Called when the train runs over the enemy
# Collision is true if the train collided with the enemy to kill it
func destroy(collision:bool):
	if collision:
		Stats.removeEmergencyRail(1)
	if "Recycle" in Stats.powersInPlay:
		Stats.addEmergencyRail(2)
		
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
		else:
			if mouseIn:
				mouseIn = false
				mouse_exited.emit()
				
