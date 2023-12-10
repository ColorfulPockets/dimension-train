extends Node
# GLOBAL VARIABLES

const base_layer = 0
const resource_counts_layer = 1
const highlight_layer = 2

const tree = Vector2i(4,2)
const rock = Vector2i(0,3)
const empty = Vector2i(0,0)
const highlight = Vector2i(2,4)
const wood = Vector2i(4,4)
const metal = Vector2i(5,4)
const rail_straight = Vector2i(6,4)
const rail_curve = Vector2i(7,4)

enum CARD_TYPES {Harvesting, Logistics, Technology}
enum CARD_FIELDS {
	Name, 
	Type, 
	TopText, 
	BottomText, 
	TopTargetArea, 
	BottomTargetArea, 
	TopFunction, 
	BottomFunction,
	}

enum CARD_STATES {
	InHand,
	FocusInHand,
	MoveDrawnCardToHand,
	ReorganizeHand,
	FocusOtherInHand
}
