class_name TrainCar extends Sprite2D

const CARGO_CAR_VAL = 3

@onready var FIXED_ELEMENTS = $"../../FixedElements"
@onready var PLAYSPACE: Playspace = $"../.."

enum TYPE {ONESHOT, STARTLEVEL, STARTTURN, ENDTURN, ENDLEVEL, TRAINMOVEMENT, EMERGENCY, OTHER}
enum RARITY {COMMON, UNCOMMON, RARE, BOSS, STARTER}

var mouseIn:bool = false
signal mouse_entered
signal mouse_exited

var carName: String
var types: Array
var rarity: RARITY

const COMMON_CARS = ["Cargo Car", "Brake Car"]
const UNCOMMON_CARS = ["Magnet Car"]
const ALL_CARS = COMMON_CARS + UNCOMMON_CARS

enum FIELDS {TOOLTIP, TYPES, RARITY}
#TODO: create github issue to turn this into a const eventually
static var CAR_INFO = {
	"Front": {
		FIELDS.TOOLTIP: "This is the front of the train.",
		FIELDS.TYPES: [TYPE.ONESHOT],
		FIELDS.RARITY: RARITY.STARTER,
		},
	"Caboose": {
		FIELDS.TOOLTIP: "This is the back of the train.",
		FIELDS.TYPES: [TYPE.ONESHOT],
		FIELDS.RARITY: RARITY.STARTER,
		},
	"Brake Car": {
		FIELDS.TOOLTIP: "Each level, the first time you would need to use emergency rail, set speed to 0 instead.",
		FIELDS.TYPES: [TYPE.EMERGENCY],
		FIELDS.RARITY: RARITY.COMMON,
		},
	"Cargo Car": {
		FIELDS.TOOLTIP: "+" + str(CARGO_CAR_VAL) + " ERC",
		FIELDS.TYPES: [TYPE.ONESHOT],
		FIELDS.RARITY: RARITY.COMMON,
		},
	"Magnet Car": {
		FIELDS.TOOLTIP: "+1 Pickup Range",
		FIELDS.TYPES: [TYPE.ONESHOT],
		FIELDS.RARITY: RARITY.UNCOMMON,
		},
	"Fusion Car": {
		FIELDS.TOOLTIP: "Each time you Gather, if you collect at least one wood and at least one metal, gain an extra random material.",
		FIELDS.TYPES: [TYPE.OTHER],
		FIELDS.RARITY: RARITY.COMMON,
		},
	"Heavy Car": {
		FIELDS.TOOLTIP: "Starter rail -5, Speed -1 (min 0)",
		FIELDS.TYPES: [TYPE.ONESHOT],
		FIELDS.RARITY: RARITY.UNCOMMON,
		},
	"Retrograde Car": {
		FIELDS.TOOLTIP: "Whenever this car moves to the left, draw a card",
		FIELDS.TYPES: [TYPE.TRAINMOVEMENT],
		FIELDS.RARITY: RARITY.RARE,
		},
	
}

func _init(carName):
	self.carName = carName
	texture = load("res://Assets/TrainCars/" + carName + ".png")
	if carName in CAR_INFO:
		var tooltip = Tooltip.new("[color=Green]"+carName+": [/color]"+CAR_INFO[carName][FIELDS.TOOLTIP], 3)
		tooltip.visuals_res = load("res://tooltip.tscn")
		add_child(tooltip)
	
	types = CAR_INFO[carName][FIELDS.TYPES]
	rarity = CAR_INFO[carName][FIELDS.RARITY]

func onGain():
	match carName:
		"Cargo Car":
			Stats.erc += CARGO_CAR_VAL
		"Magnet Car":
			Stats.startingPickupRange += 1
		"Heavy Car":
			Stats.starterRail -= 5
			if Stats.starterRail < 0:
				Stats.starterRail = 0
			Stats.startingTrainSpeed -= 1
			if Stats.startingTrainSpeed < 0:
				Stats.startingTrainSpeed = 0

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
	
func onMovement(currentLocation: Vector2i, nextLocation: Vector2i) -> void:
	match carName:
		"Retrograde Car":
			if nextLocation.x < currentLocation.x:
				await PLAYSPACE.drawCardFromDeck()

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
				
