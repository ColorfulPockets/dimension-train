extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	add_theme_font_size_override("font_size", Global.topBarFontSize)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	text = str(Stats.woodCount)
