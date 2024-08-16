class_name Enemy extends Sprite2D

@onready var FIXED_ELEMENTS = $"../../FixedElements"
@onready var PLAYSPACE = $"../.."
@onready var TERRAIN = $".."

var cell:Vector2i
var facing:Global.DIR
var health:int
var healthCounter:HealthCounter

var mouseIn:bool = false
signal mouse_entered
signal mouse_exited

var enemyName: String

const ENEMIES = ["Corrupt Slug"]

static var TOOLTIP_TEXT = {
	"Corrupt Slug": "Moves 1 space forward per turn. Leaves a trail of Corrupted terrain which removes 1 Emergency Rail when harvested.",
}

func _init(enemyName, cell:Vector2i):
	self.enemyName = enemyName
	self.cell = cell
	self.facing = Global.DIR.L
	match facing:
		Global.DIR.U:
			self.rotation -= PI/2
		Global.DIR.R:
			pass
		Global.DIR.D:
			self.rotation += PI/2
		Global.DIR.L:
			self.rotation += PI
	texture = load("res://Assets/Enemies/" + enemyName + ".png")
	if enemyName in TOOLTIP_TEXT:
		var tooltip = Tooltip.new("[color=Red]"+enemyName+": [/color]"+TOOLTIP_TEXT[enemyName], 3)
		tooltip.visuals_res = load("res://tooltip.tscn")
		add_child(tooltip)
		
	match enemyName:
		"Corrupt Slug":
			self.facing = randi_range(1,4)
			self.health = 1
	
	match self.facing:
		Global.DIR.L:
			pass
		Global.DIR.U:
			rotation += PI/2
		Global.DIR.R:
			rotation += PI
		Global.DIR.D:
			rotation -= PI/2
	

func initHealthCounter():
	healthCounter = HealthCounter.new()
	healthCounter.text = str(health)
	healthCounter.add_theme_font_size_override("font_size", 100)
	healthCounter.add_theme_constant_override("outline_size", 50)
	healthCounter.add_theme_color_override("font_outline_color", Color.BLACK)
	healthCounter.scale *= 0.1
	healthCounter.position -= healthCounter.size/2
	add_child(healthCounter)

func takeActions() -> Array[Array]:
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
			
			var occupied_cells = TERRAIN.getEnemyAndSpawnerCells()
			while cell in occupied_cells:
				var new_cell = Global.stepInDirection(cell, facing)
				# Bounce off edge
				if new_cell.x < 0 or new_cell.y < 0 or new_cell.x >= TERRAIN.mapShape.x or new_cell.y >= TERRAIN.mapShape.y:
					facing = Global.oppositeDir(facing)
				cell = Global.stepInDirection(cell, facing)
			
			
			
			return [[old_cell, cell], [old_facing, facing]]
			
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
				
