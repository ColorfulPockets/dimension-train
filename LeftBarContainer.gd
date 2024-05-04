extends Control

const SPRITE_SCALE = 9
const SPRITE_PIXELS = 16
const MARGIN_LEFT = 15
const MARGIN_TOP = 15
const COUNT_SPACE = 15
const VERTICAL_SPACE = 15

var SPRITE_SIZE = SPRITE_SCALE * SPRITE_PIXELS

func layoutCounters(counters:Array):
	# counters contains pair of $Icon, $Count
	for i in range(counters.size()):
		var icon = counters[i][0]
		var count = counters[i][1]
		
		icon.position = Vector2(MARGIN_LEFT, MARGIN_TOP	+ i*(SPRITE_SIZE + VERTICAL_SPACE))
		if icon.texture.get_width() == SPRITE_PIXELS:
			icon.scale = SPRITE_SCALE*Vector2.ONE
		else:
			icon.scale = 0.3*Vector2.ONE
		count.position = Vector2(MARGIN_LEFT + COUNT_SPACE + SPRITE_SIZE,
							MARGIN_TOP + i*(SPRITE_SIZE + VERTICAL_SPACE))

# Called when the node enters the scene tree for the first time.
func _ready():
	layoutCounters([
		[$WoodIcon, $WoodCount],
		[$MetalIcon, $MetalCount],
		[$RailIcon, $RailCount],
		[$EmergencyRailIcon, $EmergencyRailCount],
		[$CoinIcon, $CoinCount]
	])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$WoodCount.text = str(Stats.woodCount)
	$MetalCount.text = str(Stats.metalCount)
	$RailCount.text = str(Stats.railCount)
	$EmergencyRailCount.text = str(Stats.emergencyRailCount) + "\n/" + str(Stats.erc)
	$CoinCount.text = str(Stats.coinCount)
