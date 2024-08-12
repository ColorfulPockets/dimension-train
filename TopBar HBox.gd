extends HBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	size = Vector2i(size.x, $"..".size.y - 20)
	position.y  += 10


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
