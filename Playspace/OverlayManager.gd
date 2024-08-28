class_name OverlayManager extends Sprite2D

#Darkened Background management
var state = 0
var t = 0
const ALPHA = 180

const TOP_MARGIN = 400
const BOTTOM_MARGIN = 500
const SPACING = 20

# Card Management - assume cards have unique indices set
var cards:Array[CardBase] = []

func setCards(cards:Array[CardBase]):
	self.cards = cards
	cards.sort_custom(func(x:CardBase, y:CardBase): return x.CardName > y.CardName)
	
	for card in cards:
		card.position = getOverlayPosition(card.index)

func getOverlayPosition(index):
	for i:int in range(cards.size()):
		if cards[i].index == index:
			var x = i % 5
			var y = i / 5
			var centerX = (get_viewport().size / 2).x
			
			var xPos = centerX - (2-x)*(cards[i].size.x*cards[i].scale.x + SPACING)
			var yPos = TOP_MARGIN + y * (cards[i].size.y*cards[i].scale.y + SPACING)
			
			return Vector2(xPos, yPos)

const SCROLL_MULTIPLIER = -15
func _input(event):
	if state in [1,2] and cards.size() > 0 and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			pass
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			pass
	
	if state in [1,2] and cards.size() > 0 and event is InputEventPanGesture:
		if cards[0].position.y + event.delta.y*SCROLL_MULTIPLIER <= TOP_MARGIN:
			if cards[-1].position.y + event.delta.y*SCROLL_MULTIPLIER >= get_viewport().size.y - BOTTOM_MARGIN:
				for card in cards:
					card.position.y += event.delta.y * SCROLL_MULTIPLIER
	
		

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

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
				
