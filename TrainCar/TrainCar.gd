class_name TrainCar extends Node2D

const CARGO_CAR_VAL = 3

@onready var PLAYSPACE: Playspace

enum TYPE {ONESHOT, STARTLEVEL, STARTTURN, ENDTURN, ENDLEVEL, TRAINMOVEMENT, EMERGENCY, OTHER}
enum RARITY {COMMON, UNCOMMON, RARE, BOSS, STARTER}

var carName: String
var types: Array
var rarity: RARITY

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

static var commons = []
static var uncommons = []
static var rares = []
static var allCars = []
static var carListsSorted = false

static func populateLists():
	if not carListsSorted:
		for carName in CAR_INFO.keys():
			allCars.append(carName)
			if CAR_INFO[carName][FIELDS.RARITY] == RARITY.COMMON:
				commons.append(carName)
			elif CAR_INFO[carName][FIELDS.RARITY] == RARITY.UNCOMMON:
				uncommons.append(carName)
			elif CAR_INFO[carName][FIELDS.RARITY] == RARITY.RARE:
				rares.append(carName)
		
		carListsSorted = true

static func getAllCars():
	populateLists()
	return allCars


static var numCardsChosenRandomly = 0
static func getRandomCar():
	numCardsChosenRandomly += 1
	populateLists()
	
	var rarity = randi_range(0,100)
	if rarity < 50: 
		var chosen = commons.pick_random()
		return chosen
	elif rarity < 85: 
		var chosen = uncommons.pick_random()
		return chosen
	else: 
		var chosen = rares.pick_random()
		return chosen

static func getRandomRare():
	populateLists()
	return rares.pick_random()

var textureRect:TextureRect
var mouseIn = false
signal clicked
# used in shop to make sure it can't be bought again while fading out
var buyable = true

func _init(carName, tooltipPrefix = ""):
	self.carName = carName
	textureRect = TextureRect.new()
	textureRect.texture = load("res://Assets/TrainCars/" + carName + ".png")
	add_child(textureRect)
	textureRect.position -= textureRect.texture.get_size()/2
	
	textureRect.mouse_entered.connect(func(): mouseIn = true)
	textureRect.mouse_exited.connect(func(): mouseIn = false)
	
	if carName in CAR_INFO:
		var tooltip = Tooltip.new(tooltipPrefix + "[color=Green]"+carName+": [/color]"+CAR_INFO[carName][FIELDS.TOOLTIP])
		tooltip.visuals_res = load("res://tooltip.tscn")
		textureRect.add_child(tooltip)
	
	types = CAR_INFO[carName][FIELDS.TYPES]
	rarity = CAR_INFO[carName][FIELDS.RARITY]

func onGain():
	match carName:
		"Cargo Car":
			Stats.erc += CARGO_CAR_VAL
		"Magnet Car":
			Stats.startingPickupRange += 1
		"Heavy Car":
			Stats.starterMetalCount -= 5
			Stats.starterWoodCount -= 5
			if Stats.starterMetalCount < 0:
				Stats.starterMetalCount = 0
			if Stats.starterWoodCount < 0:
				Stats.starterWoodCount = 0
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
	PLAYSPACE = $"../.."
	match carName:
		"Retrograde Car":
			if nextLocation.x < currentLocation.x:
				await PLAYSPACE.drawCardFromDeck()

func animateBrakes():
	textureRect.texture = load("res://Assets/TrainCars/Brake Car_engaged.png")
	await get_tree().create_timer(0.1).timeout
	textureRect.texture = load("res://Assets/TrainCars/Brake Car_used.png")
	await get_tree().create_timer(0.2).timeout
	textureRect.texture = load("res://Assets/TrainCars/Brake Car_engaged.png")
	await get_tree().create_timer(0.1).timeout
	textureRect.texture = load("res://Assets/TrainCars/Brake Car_used.png")
	
	
func _input(event):
	if event is InputEventMouseButton and mouseIn:
		clicked.emit()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

