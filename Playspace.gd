extends Node2D

const CardBase = preload("res://Cards/CardBase.tscn")
const PlayerHand = preload("res://Cards/PlayerHand.gd")

@onready var cdt = preload("res://CardDataTypes.gd").new()

@onready var deck = ["Mine", "Chop", "Transport", "Build"]

@onready var viewportSize = Vector2(get_viewport().size)

@onready var cardOvalCenter = viewportSize* Vector2(0.5,1.3)
@onready var horizontalRadius = viewportSize.x*0.45
@onready var verticalRadius = viewportSize.y*0.4
var angle = deg_to_rad(90)
var ovalAngleVector = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	print(get_viewport().size)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



const CARDSIZE = Vector2(250/2,350/2)
# How much the cards should be rotated compared to their position on the ellipse
const CARD_ANGLE = float(1)/float(4)

func drawCard(fromPosition):
	var new_card = CardBase.instantiate()
	new_card.CardName = deck[0]
	ovalAngleVector = Vector2(horizontalRadius * cos(angle), - verticalRadius * sin(angle))
	print(new_card.size)
	new_card.scale = CARDSIZE / new_card.size
	
	new_card.startpos = fromPosition
	new_card.targetpos = cardOvalCenter + ovalAngleVector - CARDSIZE
	
	new_card.startrot = 0
		# This lets the cards rotate a little bit, but still remain mostly upright.
	new_card.targetrot = (-angle + deg_to_rad(90))*CARD_ANGLE
	
	print(new_card.targetrot)
	
	angle += deg_to_rad(10)
	#print(angle)
	
	$Cards.add_child(new_card)
	new_card.state = cdt.CARD_STATES.MoveDrawnCardToHand
	deck.pop_front()
