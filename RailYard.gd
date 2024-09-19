extends Control

var RefactorScene = preload("res://refactor_screen.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var selectCardsView = DeckView.new(Stats.deck, 3)
	add_child(selectCardsView)
	selectCardsView.backButtonPressed.connect(func(): 
		selectCardsView.queue_free()
		# TODO: Make it a skip button instead of Back, or add another option or something
		)
	selectCardsView.confirmPressed.connect(func(cardsSelected):
		for cardName in cardsSelected:
			Stats.deck.remove_at(Stats.deck.find(cardName))
		var refactorScene = RefactorScene.instantiate()
		refactorScene.refactor_chosen.connect(
			func(refactoredCards):
				Stats.deck += refactoredCards
				refactorScene.queue_free()
		)
		add_child(refactorScene)
		refactorScene.populateCards(cardsSelected)
		selectCardsView.queue_free()
		)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
