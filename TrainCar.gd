class_name TrainCar extends Sprite2D

enum TYPE {ONESHOT, STARTLEVEL, STARTTURN, ENDTURN, ENDLEVEL, TRAINMOVEMENT, EMERGENCY}
enum RARITY {COMMON, UNCOMMON, RARE, BOSS, STARTER}

var carName: String
var types: Array[TYPE]
var rarity: RARITY

const COMMON_CARS = ["Cargo Car", "Brake Car"]

func _init(carName):
	self.carName = carName
	texture = load("res://Assets/TrainCars/" + carName + ".png")
	
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
