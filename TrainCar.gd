class_name TrainCar extends Sprite2D

const CARGO_CAR_VAL = 3

@onready var FIXED_ELEMENTS = $"../../FixedElements"

enum TYPE {ONESHOT, STARTLEVEL, STARTTURN, ENDTURN, ENDLEVEL, TRAINMOVEMENT, EMERGENCY}
enum RARITY {COMMON, UNCOMMON, RARE, BOSS, STARTER}

var mouseIn:bool = false
signal mouse_entered
signal mouse_exited

var carName: String
var types: Array[TYPE]
var rarity: RARITY

const COMMON_CARS = ["Cargo Car", "Brake Car"]
const UNCOMMON_CARS = []
const ALL_CARS = COMMON_CARS + UNCOMMON_CARS

static var TOOLTIP_TEXT = {
	"Cargo Car": "+" + str(CARGO_CAR_VAL) + " ERC",
	"Brake Car": "Each level, the first time you would need to use emergency rail, set speed to 0 instead.",
}

func _init(carName):
	self.carName = carName
	texture = load("res://Assets/TrainCars/" + carName + ".png")
	if carName in TOOLTIP_TEXT:
		var tooltip = Tooltip.new("[color=Green]"+carName+": [/color]"+TOOLTIP_TEXT[carName], 3)
		tooltip.visuals_res = load("res://tooltip.tscn")
		add_child(tooltip)
	
	match carName:
		"Front":
			types = [TYPE.ONESHOT]
			rarity = RARITY.STARTER
		"Caboose":
			types = [TYPE.ONESHOT]
			rarity = RARITY.STARTER
		"Cargo Car":
			types = [TYPE.ONESHOT]
			rarity = RARITY.COMMON
		"Brake Car":
			types = [TYPE.EMERGENCY]
			rarity = RARITY.COMMON

func onGain():
	match carName:
		"Cargo Car":
			Stats.erc += 3

var brakeUsed = false

# Returns: whether something has been done which might affect if there's an emergency
func onEmergency() -> bool:
	match carName:
		"Brake Car":
			if not brakeUsed:
				Stats.trainSpeed = 0
				brakeUsed = true
				animateBrakes()
				return true
	
	return false

func animateBrakes():
	texture = load("res://Assets/TrainCars/Brake Car_engaged.png")
	await get_tree().create_timer(0.1).timeout
	texture = load("res://Assets/TrainCars/Brake Car_used.png")
	await get_tree().create_timer(0.2).timeout
	texture = load("res://Assets/TrainCars/Brake Car_engaged.png")
	await get_tree().create_timer(0.1).timeout
	texture = load("res://Assets/TrainCars/Brake Car_used.png")
	
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
				
