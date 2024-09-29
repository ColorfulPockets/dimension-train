extends HBoxContainer

# When we are animating the train on the overworld, can't dismiss overworld
var ignorePresses = false

# Called when the node enters the scene tree for the first time.
func _ready():
	size = Vector2i(size.x, $"..".size.y - 20)
	position.y  += 10
	$OverworldViewButton.pressed.connect(func():
		if not ignorePresses:
			$"../../Overworld".visible = not $"../../Overworld".visible
		)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
