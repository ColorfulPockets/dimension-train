class_name Debuff extends TextureRect

const DEBUFF_TOOLTIP = {
	"Slimed": "For the next VALUE turn(s), each resource you Gather has a 50% chance to not be gathered.",
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
	custom_minimum_size = Vector2(150,150)
	texture = load("res://Assets/Debuffs/" + debuffName + ".png")
	
	
	
	var tooltip = Tooltip.new(process_tooltip(), 4)
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
	var tooltipText:String
	pattern.compile(r'VALUE')
	var matches = pattern.search_all(DEBUFF_TOOLTIP[debuffName])
	for match in matches:
		var key = match.get_string(1)	# get the matched argument name
		var replacement = str(value)
		tooltipText = DEBUFF_TOOLTIP[debuffName].replace("VALUE", replacement)
		
	return "[color=Red]"+debuffName+": [/color]" + tooltipText

func endTurn():
	match debuffName:
		"Slimed":
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
