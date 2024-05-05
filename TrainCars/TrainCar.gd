class_name TrainCar extends Sprite2D

enum TYPE {ONESHOT, STARTLEVEL, STARTTURN, ENDTURN, ENDLEVEL, TRAINMOVEMENT}
enum RARITY {COMMON, UNCOMMON, RARE, BOSS, STARTER}

var carName: String
var types: Array[TYPE]
var rarity: RARITY

const COMMON_CARS = ["Cargo Car"]

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

func onGain():
	match carName:
		"Cargo Car":
			Stats.erc += 3

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
