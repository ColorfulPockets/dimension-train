extends TextureButton

var showing = false
@onready var discardPile = $".."/DiscardPile
@onready var darkenedBackground = $".."/DarkenedBackground
@onready var PLAYSPACE:Playspace = $"../.."

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func fadeOutCards():
	showing = false
	for card in PLAYSPACE.drawPile:
		card.fadeOut()
		
	if PLAYSPACE.drawPile.size() > 0:
		await PLAYSPACE.drawPile[0].fadeOut()
		
	for card in PLAYSPACE.drawPile:
		card.state = Global.CARD_STATES.InDrawPile

func stop_showing():
	fadeOutCards()
		
	if darkenedBackground.state != -1:
		darkenedBackground.state = 0
		
	#await get_tree().create_timer(Global.FADE_TIME).timeout

func start_showing():
	showing = true
	
	for card in PLAYSPACE.drawPile:
		card.moveToOverlay()
		
	darkenedBackground.setCards(PLAYSPACE.drawPile)
	
	if darkenedBackground.state != 2:
		darkenedBackground.state = 1

func _pressed():
	if showing:
		stop_showing()
		Global.overlayHidden.emit()
	else:
		discardPile.fadeOutCards()
		start_showing()
		Global.overlayShowing.emit()
		
func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE:
			if event.pressed:
				if showing:
					stop_showing()
					Global.overlayHidden.emit()
