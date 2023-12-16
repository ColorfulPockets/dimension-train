extends Node

# GLOBAL SIGNALS
signal cardFunctionStarted
signal cardFunctionEnded

# GLOBAL VARIABLES

const base_layer = 0
const resource_counts_layer = 1
const animation_layer = 2
const fog_layer = 3
const highlight_layer = 4

const TRAIN_MOVEMENT_TIME = 0.5

const DRAW_PILE_POSITION = Vector2(30,1850)
const DISCARD_PILE_POSITION = Vector2(3570,1850)
const END_TURN_BUTTON_POSITION = Vector2(3470,1350)
const ENERGY_DISPLAY_POSITION = Vector2(400,1350)
const SPEED_CONTAINER_POSITION = Vector2(3450, 150)

const VIEWPORT_SIZE = Vector2(3840, 2160)

const TILE_SHAPE = Vector2i(10,10)

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
const rail_endpoint = Vector2i(6,3)
const train_front_sideview = Vector2i(6,5)
const train_middle_sideview = Vector2i(7,5)
const train_end_sideview = Vector2i(8,5)
const train_front_topview = Vector2i(6,6)
const train_middle_topview = Vector2i(6,7)
const train_end_topview = Vector2i(6,8)
const train_front_turning = Vector2i(7,6)
const train_middle_turning = Vector2i(8,6)
const train_end_turning = Vector2i(9,6)
const water = Vector2i(0,28)
const fog = Vector2i(11,4)
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
	EnergyCost,
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

var flipH = TileSetAtlasSource.TRANSFORM_FLIP_H
var flipV = TileSetAtlasSource.TRANSFORM_FLIP_V
var transpose = TileSetAtlasSource.TRANSFORM_TRANSPOSE

# these assume that the default orientation for a straight piece is in_down_out_up
# and for a curve piece in_down_out_right
var in_left_out_down = flipH | transpose
var in_up_out_left = flipH | flipV
var in_right_out_up = transpose | flipV

var in_right_out_down = transpose
var in_down_out_left = flipH
var in_up_out_right = flipV
var in_left_out_up = flipH | flipV | transpose

var in_right_out_left = transpose | flipV
var in_left_out_right = flipH | transpose
var in_up_out_down = flipH | flipV

enum DIR {NONE, L, R, U, D}

enum DIRECTIONAL_TILES {TRAIN_FRONT, TRAIN_MIDDLE, TRAIN_END, RAIL, RAIL_END}

# Access with DIRECTIONAL_TILES[tileName][in_direction][out_direction]
# Return value is [tile_atlas, transform_code]
var DIRECTIONAL_TILE_INOUT = {
	DIRECTIONAL_TILES.RAIL_END: {
		DIR.L: {
			DIR.R: [rail_endpoint, in_left_out_right]
		},
		DIR.R: {
			DIR.L: [rail_endpoint, in_right_out_left]
		},
		DIR.U:{
			DIR.D: [rail_endpoint, in_up_out_down]
		},
		DIR.D:{
			DIR.U: [rail_endpoint, 0]
		},	
	},
	DIRECTIONAL_TILES.TRAIN_FRONT: {
		DIR.L: {
			DIR.U: [train_front_turning, in_left_out_up],
			DIR.D: [train_front_turning, in_left_out_down],
			DIR.R: [train_front_topview, in_left_out_right],
		},
		DIR.R: {
			DIR.U: [train_front_turning, in_right_out_up],
			DIR.D: [train_front_turning, in_right_out_down],
			DIR.L: [train_front_topview, in_right_out_left]
		},
		DIR.U: {
			DIR.R: [train_front_turning, in_up_out_right],
			DIR.L: [train_front_turning, in_up_out_left],
			DIR.D: [train_front_topview, in_up_out_down]
		},
		DIR.D: {
			DIR.R: [train_front_turning, 0],
			DIR.L: [train_front_turning, in_down_out_left],
			DIR.U: [train_front_topview, 0]
		}	
	},
	DIRECTIONAL_TILES.TRAIN_MIDDLE: {
		DIR.L: {
			DIR.U: [train_middle_turning, in_left_out_up],
			DIR.D: [train_middle_turning, in_left_out_down],
			DIR.R: [train_middle_topview, in_left_out_right],
		},
		DIR.R: {
			DIR.U: [train_middle_turning, in_right_out_up],
			DIR.D: [train_middle_turning, in_right_out_down],
			DIR.L: [train_middle_topview, in_right_out_left]
		},
		DIR.U: {
			DIR.R: [train_middle_turning, in_up_out_right],
			DIR.L: [train_middle_turning, in_up_out_left],
			DIR.D: [train_middle_topview, in_up_out_down]
		},
		DIR.D: {
			DIR.R: [train_middle_turning, 0],
			DIR.L: [train_middle_turning, in_down_out_left],
			DIR.U: [train_middle_topview, 0]
		}	
	},
	DIRECTIONAL_TILES.TRAIN_END: {
		DIR.L: {
			DIR.U: [train_end_turning, in_left_out_up],
			DIR.D: [train_end_turning, in_left_out_down],
			DIR.R: [train_middle_topview, in_left_out_right],
		},
		DIR.R: {
			DIR.U: [train_end_turning, in_right_out_up],
			DIR.D: [train_end_turning, in_right_out_down],
			DIR.L: [train_middle_topview, in_right_out_left]
		},
		DIR.U: {
			DIR.R: [train_end_turning, in_up_out_right],
			DIR.L: [train_end_turning, in_up_out_left],
			DIR.D: [train_end_topview, in_up_out_down]
		},
		DIR.D: {
			DIR.R: [train_end_turning, 0],
			DIR.L: [train_end_turning, in_down_out_left],
			DIR.U: [train_end_topview, 0]
		}
	},	
	DIRECTIONAL_TILES.RAIL: {
		DIR.L: {
			DIR.U: [rail_curve, in_left_out_up],
			DIR.D: [rail_curve, in_left_out_down],
			DIR.R: [rail_straight, in_left_out_right],
		},
		DIR.R: {
			DIR.U: [rail_curve, in_right_out_up],
			DIR.D: [rail_curve, in_right_out_down],
			DIR.L: [rail_straight, in_right_out_left]
		},
		DIR.U: {
			DIR.R: [rail_curve, in_up_out_right],
			DIR.L: [rail_curve, in_up_out_left],
			DIR.D: [rail_straight, in_up_out_down]
		},
		DIR.D: {
			DIR.R: [rail_curve, 0],
			DIR.L: [rail_curve, in_down_out_left],
			DIR.U: [rail_straight, 0]
		}
	}	
}
