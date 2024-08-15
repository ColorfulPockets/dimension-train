extends Sprite2D

@onready var text = $Label

# Called when the node enters the scene tree for the first time.
func _ready():
	position = Global.ENERGY_DISPLAY_POSITION
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$Label.text = str(Stats.currentEnergy) + "/" + str(Stats.maxEnergy)
