extends PanelContainer

var tooltip:Tooltip
@onready var tooltip_exists:bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	#setText("Testing Text\n+[color=Green]Cargo Car[/color]")
	pass

func setText(text:String):
	$"./Label".text = text
	if tooltip_exists:
		remove_child(tooltip)
	tooltip = Tooltip.new("", 2)
	add_child(tooltip)
	tooltip_exists = true
	
	var lines = text.split("\n")
	
	for line in lines:
		# TODO: Clean up this hard coded stuff
		line = line.erase(0, len("+[color=Green]"))
		line = line.erase(line.find("[/color]"), len("[/color]"))
		if line in TrainCar.getAllCars():
			tooltip.text += "\n[color=Green]" + line + "[/color]: " + TrainCar.CAR_INFO[line][TrainCar.FIELDS.TOOLTIP]
	
	tooltip.text = tooltip.text.erase(0)
	
	if tooltip.text == "":
		remove_child(tooltip)
		tooltip_exists = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(tooltip_exists)
	pass
