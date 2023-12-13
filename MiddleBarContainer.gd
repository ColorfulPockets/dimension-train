class_name MiddleBarContainer extends Control

enum POSITIONS {TOP, ABOVE_CARDS}
@onready var middleBarText:MiddleBarText = $Text

# Called when the node enters the scene tree for the first time.
func _ready():
	position = (get_viewport().size - Vector2i(size)) / 2 + Vector2i(0,150)
	$MiddleBar.scale = size
	textChanged()
	$Text.changed.connect(textChanged)
	
func textChanged():
	$Text.position = size / 2 - $Text.size/2

func setText(text):
	middleBarText.setText(text)

func setPosition(location):
	if location == POSITIONS.ABOVE_CARDS:
		position = (get_viewport().size - Vector2i(size)) / 2 + Vector2i(0,150)
	elif location == POSITIONS.TOP:
		position = (get_viewport().size - Vector2i(size))/2
		position.y = 0 + size.y/2 + 50

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
