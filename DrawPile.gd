extends TextureButton

# Called when the node enters the scene tree for the first time.
func _ready():
	scale *= 0.45
	position = Global.DRAW_PILE_POSITION


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
#func _pressed():
	#$'../../'.drawCard(position + Vector2(0,-130), Vector2(0,0))
