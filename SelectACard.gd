class_name SelectACard extends Sprite2D

#Darkened Background management
var state = 0
var t = 0
const ALPHA = 180

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func selectNCards(numCards:int):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match state:
		#Full out
		-1:
			pass
		#Fading out
		0:
			if t < 1:
				#0 to 255
				modulate.a8 = ALPHA - t*ALPHA
				t += delta/float(Global.FADE_TIME)
			else:
				t = 0
				modulate.a8 = 0
				state = -1
		#Fading in
		1:
			if t < 1:
				#0 to 255
				modulate.a8 = t*ALPHA
				t += delta/float(Global.FADE_TIME)
			else:
				t = 0
				modulate.a8 = ALPHA
				state = 2
		#Full in
		2:
			pass
				
