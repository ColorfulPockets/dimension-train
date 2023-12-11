extends Node
# GLOBAL VARIABLES

const base_layer = 0
const resource_counts_layer = 1
const animation_layer = 2
const highlight_layer = 3

const DRAW_PILE_POSITION = Vector2(30,1850)
const DISCARD_PILE_POSITION = Vector2(3570,1850)
const END_TURN_BUTTON_POSITION = Vector2(3470,1350)

const tree = Vector2i(4,2)
const rock = Vector2i(0,3)
const empty = Vector2i(0,0)
const highlight = Vector2i(2,4)
const wood = Vector2i(4,4)
const metal = Vector2i(10,4)
const metal_shine1 = Vector2i(8,4)
const metal_shine2 = Vector2i(9,4)
const rail_straight = Vector2i(6,4)
const rail_curve = Vector2i(7,4)
const rail_tiles = [rail_straight, rail_curve]
const delete = Vector2i(-1, -1)

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
	Arguments,
	TopMousePointer,
	BottomMousePointer,
	}

enum CARD_STATES {
	InDrawPile,
	InDiscardPile,
	InHand,
	FocusInHand,
	MoveDrawnCardToHand,
	ReorganizeHand,
	FocusOtherInHand
}

enum FUNCTION_STATES {Shift, Unshift, Success, Fail}
