extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready():
	position = Global.END_TURN_BUTTON_POSITION

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _pressed():
	$"../..".endTurn()
