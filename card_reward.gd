extends Node2D

@onready var CardDb = preload("res://CardDatabase.gd").new()

# Called when the node enters the scene tree for the first time.
func _ready():
	chooseCards()

func chooseCards():
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
