extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	var selectCardsView = DeckView.new(Stats.deck, 1)
	add_child(selectCardsView)
	selectCardsView.backButtonPressed.connect(func(): 
		selectCardsView.queue_free()
		# TODO: Make it a skip button instead of Back, or add another option or something
		)
	selectCardsView.confirmPressed.connect(func(cardsSelected):
		
		selectCardsView.queue_free()
		)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
