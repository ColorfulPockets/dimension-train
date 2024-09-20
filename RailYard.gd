extends Control

signal choice_made

var RefactorScene = preload("res://refactor_screen.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	$"MarginContainer/HBoxContainer/Research/Research Button".pressed.connect(research)
	$"MarginContainer/HBoxContainer/Resupply/Resupply Button".pressed.connect(resupply)
	

func resupply():
	Stats.addEmergencyRail(5)
	choice_made.emit()

func research():
	var selectCardsView = DeckView.new(Stats.deck, 3)
	add_child(selectCardsView)
	selectCardsView.backButtonPressed.connect(func(): 
		selectCardsView.queue_free()
		)
	selectCardsView.confirmPressed.connect(func(cardsSelected):
		for cardName in cardsSelected:
			Stats.deck.remove_at(Stats.deck.find(cardName))
		var refactorScene = RefactorScene.instantiate()
		refactorScene.refactor_chosen.connect(
			func(refactoredCards):
				Stats.deck += refactoredCards
				refactorScene.queue_free()
				choice_made.emit()
		)
		add_child(refactorScene)
		refactorScene.populateCards(cardsSelected)
		selectCardsView.queue_free()
		)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
