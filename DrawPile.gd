extends TextureButton

# Called when the node enters the scene tree for the first time.
func _ready():
	scale *= 0.15
	position = Vector2(10,550)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _pressed():
	$'../../'.drawCard(position)
