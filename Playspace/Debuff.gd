class_name Debuff extends TextureRect

enum {TOOLTIP, CATEGORY}
enum CATEGORIES {DECREMENT, PERMANENT, NONE}

const DEBUFF_INFO = {
	"Slimed": {
		TOOLTIP: "For the next VALUE turn(s), each resource you Gather has a 50% chance to not be gathered.",
		CATEGORY: CATEGORIES.DECREMENT,
		},
	"Increase": { 
		TOOLTIP: "This spawner will increase the number of enemies it spawns by 1.",
		CATEGORY: CATEGORIES.NONE,
		},
	"Explosion": {
		TOOLTIP: "After they move, all Fire Giants will deal 5 damage within 2 cells.",
		CATEGORY: CATEGORIES.NONE,
		},
	"Shaken": {
		TOOLTIP: "For the next VALUE turn(s), each emergency rail placed costs two rails instead of 1.",
		CATEGORY: CATEGORIES.DECREMENT,
		},
}

var value = 1
var valueLabel:Label
var debuffName
var isPreview:bool = false

func _init(debuffName:String, value, isPreview:bool = false, scale:float = 1):
	self.debuffName = debuffName
	self.isPreview = isPreview
	self.scale *= scale
	self.value = value
	custom_minimum_size = Vector2(128,128)
	texture = load("res://Assets/Debuffs/" + debuffName + ".png")
	
	var tooltip = Tooltip.new(process_tooltip())
	tooltip.visuals_res = load("res://tooltip.tscn")
	add_child(tooltip)
	if not isPreview:
		valueLabel = Label.new()
		valueLabel.text = str(value)
		valueLabel.add_theme_font_size_override("font_size", 50)
		add_child(valueLabel)
				

func process_tooltip():
	# VALUE replacement in Tooltip
	var pattern = RegEx.new()
	var tooltipText:String = DEBUFF_INFO[debuffName][TOOLTIP]
	pattern.compile(r'VALUE')
	var matches = pattern.search_all(DEBUFF_INFO[debuffName][TOOLTIP])
	for match in matches:
		var key = match.get_string(1)	# get the matched argument name
		var replacement = str(value)
		tooltipText = DEBUFF_INFO[debuffName][TOOLTIP].replace("VALUE", replacement)
		
	return "[color=Red]"+debuffName+": [/color]" + tooltipText

func endTurn():
	if DEBUFF_INFO[debuffName][CATEGORY] == CATEGORIES.DECREMENT:
		Stats.debuffs[debuffName] -= 1
		if Stats.debuffs[debuffName] == 0:
			Stats.debuffs.erase(debuffName)

var bobbing_speed = 2
var bobbing_amount = 5
@onready var original_y = position.y
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# Bob up and down above the spawner
	if isPreview:
		# Calculate the new y position using sine wave function
		var bobbing_offset = sin(Time.get_ticks_msec() * bobbing_speed * 0.001) * bobbing_amount
		position.y = original_y + bobbing_offset
