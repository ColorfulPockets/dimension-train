extends Node

# GLOBAL SIGNALS
signal cardFunctionStarted
signal cardFunctionEnded

signal overlayShowing
signal overlayHidden

# GLOBAL VARIABLES

const base_layer = 0
const resource_counts_layer = 1
const animation_layer = 2
const rail_layer = 3
const temporary_rail_layer = 4
const fog_layer = 5
const grid_layer = 6
const highlight_layer = 7
const enemy_layer = 8
const max_layer = 8

const TRAIN_MOVEMENT_TIME = 0.5
const FADE_TIME = 0.2

const DRAW_PILE_POSITION = Vector2(30,1850)
const DISCARD_PILE_POSITION = Vector2(3570,1850)
const DECK_POSITION = Vector2(3570,50)
const END_TURN_BUTTON_POSITION = Vector2(3470,1350)
const ENERGY_DISPLAY_POSITION = Vector2(400,1350)
const SPEED_CONTAINER_POSITION = Vector2(3450, 150)
const POWER_POSITION = Vector2(3840/2, 2160/2)

const VIEWPORT_SIZE = Vector2(3840, 2160)

const TILE_SHAPE = Vector2i(10,10)

const tree = Vector2i(4,2)
const corrupt_tree = Vector2i(3,2)
const trees = [tree, corrupt_tree]
const rock = Vector2i(0,3)
const corrupt_rock = Vector2i(1,3)
const rocks = [rock, corrupt_rock]
const empty = Vector2i(0,0)
const bridge = Vector2i(5,6)
const highlight = Vector2i(2,4)
const grid_outline = Vector2i(1,4)
const wood = Vector2i(4,4)
const metal = Vector2i(10,4)
const collectable = [wood, metal]
const metal_shine1 = Vector2i(8,4)
const metal_shine2 = Vector2i(9,4)
const rail_straight = Vector2i(6,4)
const rail_curve = Vector2i(7,4)
const rail_endpoint = Vector2i(6,3)
const rail_tiles = [rail_straight, rail_curve, rail_endpoint]
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
const empty_tiles = [empty, bridge]

enum CARD_TYPES {Harvesting, Logistics, Technology}
enum CARD_FIELDS {
	Name, 
	Type, 
	Text,
	TargetArea,
	Function,
	Arguments,
	MousePointer,
	EnergyCost,
	Rarity,
	}

enum CARD_STATES {
	InDrawPile,
	InDiscardPile,
	InHand,
	FocusInHand,
	MoveDrawnCardToHand,
	ReorganizeHand,
	FocusOtherInHand,
	InOverlay,
	InDeck,
	InPower,
}

enum FUNCTION_STATES {Waiting, Success, Fail, Power}

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

func oppositeDir(dir):
	if dir == DIR.L:
		return DIR.R
	elif dir == DIR.R:
		return DIR.L
	elif dir == DIR.U:
		return DIR.D
	elif dir == DIR.D:
		return DIR.U
	else:
		return DIR.NONE
		
	
func nextDirClockwise(dir):
	if dir == DIR.L:
		return DIR.U
	elif dir == DIR.R:
		return DIR.D
	elif dir == DIR.U:
		return DIR.R
	elif dir == DIR.D:
		return DIR.L
	else:
		return DIR.NONE
	
func stepInDirection(position:Vector2i, dir):
	match dir:
		DIR.L:
			return position + Vector2i(-1,0)
		DIR.R:
			return position + Vector2i(1,0)
		DIR.D:
			return position + Vector2i(0,1)
		DIR.U:
			return position + Vector2i(0,-1)
		
	return Vector2i(-1,-1)

enum DIRECTIONAL_TILES {TRAIN_FRONT, TRAIN_MIDDLE, TRAIN_END, RAIL, RAIL_END}

# Access with DIRECTIONAL_TILE_INOUT[tileName][in_direction][out_direction]
# Return value is [tile_atlas, transform_code]
var DIRECTIONAL_TILE_INOUT = {
	DIRECTIONAL_TILES.RAIL_END: {
		DIR.L: {
			DIR.R: [rail_endpoint, in_left_out_right],
			DIR.L: [rail_endpoint, in_left_out_right],
			DIR.U: [rail_endpoint, in_left_out_right],
			DIR.D: [rail_endpoint, in_left_out_right],
		},
		DIR.R: {
			DIR.L: [rail_endpoint, in_right_out_left],
			DIR.R: [rail_endpoint, in_right_out_left],
			DIR.U: [rail_endpoint, in_right_out_left],
			DIR.D: [rail_endpoint, in_right_out_left],
		},
		DIR.U:{
			DIR.D: [rail_endpoint, in_up_out_down],
			DIR.U: [rail_endpoint, in_up_out_down],
			DIR.R: [rail_endpoint, in_up_out_down],
			DIR.L: [rail_endpoint, in_up_out_down],
		},
		DIR.D:{
			DIR.U: [rail_endpoint, 0],
			DIR.D: [rail_endpoint, 0],
			DIR.R: [rail_endpoint, 0],
			DIR.L: [rail_endpoint, 0],
		},	
	},
	DIRECTIONAL_TILES.TRAIN_FRONT: {
		DIR.L: {
			DIR.U: [train_front_turning, in_left_out_up],
			DIR.D: [train_front_turning, in_left_out_down],
			DIR.R: [train_front_topview, in_left_out_right],
			DIR.L: [train_front_topview, in_left_out_right],
		},
		DIR.R: {
			DIR.U: [train_front_turning, in_right_out_up],
			DIR.D: [train_front_turning, in_right_out_down],
			DIR.L: [train_front_topview, in_right_out_left],
			DIR.R: [train_front_topview, in_right_out_left],
		},
		DIR.U: {
			DIR.R: [train_front_turning, in_up_out_right],
			DIR.L: [train_front_turning, in_up_out_left],
			DIR.D: [train_front_topview, in_up_out_down],
			DIR.U: [train_front_topview, in_up_out_down],
		},
		DIR.D: {
			DIR.R: [train_front_turning, 0],
			DIR.L: [train_front_turning, in_down_out_left],
			DIR.U: [train_front_topview, 0],
			DIR.D: [train_front_topview, 0],
		}	
	},
	DIRECTIONAL_TILES.TRAIN_MIDDLE: {
		DIR.L: {
			DIR.U: [train_middle_turning, in_left_out_up],
			DIR.D: [train_middle_turning, in_left_out_down],
			DIR.R: [train_middle_topview, in_left_out_right],
			DIR.L: [train_middle_topview, in_left_out_right],
		},
		DIR.R: {
			DIR.U: [train_middle_turning, in_right_out_up],
			DIR.D: [train_middle_turning, in_right_out_down],
			DIR.L: [train_middle_topview, in_right_out_left],
			DIR.R: [train_middle_topview, in_right_out_left],
		},
		DIR.U: {
			DIR.R: [train_middle_turning, in_up_out_right],
			DIR.L: [train_middle_turning, in_up_out_left],
			DIR.D: [train_middle_topview, in_up_out_down],
			DIR.U: [train_middle_topview, in_up_out_down],
		},
		DIR.D: {
			DIR.R: [train_middle_turning, 0],
			DIR.L: [train_middle_turning, in_down_out_left],
			DIR.U: [train_middle_topview, 0],
			DIR.D: [train_middle_topview, 0],
		}	
	},
	DIRECTIONAL_TILES.TRAIN_END: {
		DIR.L: {
			DIR.U: [train_end_turning, in_left_out_up],
			DIR.D: [train_end_turning, in_left_out_down],
			DIR.R: [train_middle_topview, in_left_out_right],
			DIR.L: [train_middle_topview, in_left_out_right],
		},
		DIR.R: {
			DIR.U: [train_end_turning, in_right_out_up],
			DIR.D: [train_end_turning, in_right_out_down],
			DIR.L: [train_middle_topview, in_right_out_left],
			DIR.R: [train_middle_topview, in_right_out_left],
		},
		DIR.U: {
			DIR.R: [train_end_turning, in_up_out_right],
			DIR.L: [train_end_turning, in_up_out_left],
			DIR.D: [train_end_topview, in_up_out_down],
			DIR.U: [train_end_topview, in_up_out_down]
		},
		DIR.D: {
			DIR.R: [train_end_turning, 0],
			DIR.L: [train_end_turning, in_down_out_left],
			DIR.U: [train_end_topview, 0],
			DIR.D: [train_end_topview, 0],
		}
	},	
	DIRECTIONAL_TILES.RAIL: {
		DIR.L: {
			DIR.U: [rail_curve, in_left_out_up],
			DIR.D: [rail_curve, in_left_out_down],
			DIR.R: [rail_straight, in_left_out_right],
			DIR.L: [rail_straight, in_left_out_right],
		},
		DIR.R: {
			DIR.U: [rail_curve, in_right_out_up],
			DIR.D: [rail_curve, in_right_out_down],
			DIR.L: [rail_straight, in_right_out_left],
			DIR.R: [rail_straight, in_right_out_left],
		},
		DIR.U: {
			DIR.R: [rail_curve, in_up_out_right],
			DIR.L: [rail_curve, in_up_out_left],
			DIR.D: [rail_straight, in_up_out_down],
			DIR.U: [rail_straight, in_up_out_down],
		},
		DIR.D: {
			DIR.R: [rail_curve, 0],
			DIR.L: [rail_curve, in_down_out_left],
			DIR.U: [rail_straight, 0],
			DIR.D: [rail_straight, 0]
		}
	}	
}


var rewards = {}
var selectedReward

func clearRewards():
	rewards = {}

const CARD_VALUE = 6
const EMERGENCY_TRACK_VALUE = 1
const GOLD_VALUE = 2
const SHOP_VALUE = 6
const COMMON_CAR_VALUE = 12
const PLUS_SPEED_VALUE = -12
const MINUS_SPEED_VALUE = 6

func addReward(cell:Vector2i, rewardValue:float):
	var reward = []
	if Stats.levelCounter % 2 == 1:
		reward.append("PlusSpeed")
	if randi_range(0,3) == 0:
		reward.append("PlusSpeed")
		rewardValue -= PLUS_SPEED_VALUE
	if rewardValue >= COMMON_CAR_VALUE:
		reward.append(TrainCar.COMMON_CARS.pick_random())
		rewardValue -= COMMON_CAR_VALUE
	if rewardValue >= CARD_VALUE:
		reward.append("Card")
		rewardValue -= CARD_VALUE
	
	while rewardValue > 0:
		var extra_reward = randi_range(0,6)
		match extra_reward:
			0:
				if rewardValue >= CARD_VALUE:
					reward.append("Card")
					rewardValue -= CARD_VALUE
			1:
				reward.append("ER")
				rewardValue -= EMERGENCY_TRACK_VALUE
			2:
				if rewardValue >= GOLD_VALUE:
					reward.append("Gold")
					rewardValue -= GOLD_VALUE
			3:
				if rewardValue >= SHOP_VALUE and "Shop" not in reward:
					reward.append("Shop")
					rewardValue -= SHOP_VALUE
			4:
				if rewardValue >= COMMON_CAR_VALUE:
					reward.append(TrainCar.COMMON_CARS.pick_random())
					rewardValue -= COMMON_CAR_VALUE
			5:
				if "PlusSpeed" not in reward and rewardValue >= MINUS_SPEED_VALUE:
					reward.append("MinusSpeed")
					rewardValue -= MINUS_SPEED_VALUE
					
	rewards[cell] = reward

func getRewardText(cell) -> String:
	var card_count = 0
	var shop_count = 0
	var gold_count = 0
	var er_count = 0
	var minus_count = 0
	var plus_count = 0
	
	var reward_string = ""
	
	for reward in rewards[cell]:
		match reward:
			"Card": card_count += 1
			"Shop": shop_count += 1
			"Gold": gold_count += 1
			"ER": er_count += 1
			"MinusSpeed": minus_count += 1
			"PlusSpeed": plus_count += 1
		if " Car" in reward:
			reward_string += "\n+[color=Green]" + reward + "[/color]"
 		
	if card_count == 1:
		reward_string += "\n+1 Card"
	elif card_count > 1:
		reward_string += "\n+" + str(card_count) + " Cards"
	if shop_count > 0:
		reward_string += "\n+Shop"
	if gold_count > 0:
		reward_string += "\n+" + str(gold_count) + " Gold"
	if er_count > 0:
		reward_string += "\n+" + str(er_count) + " ER"
	if minus_count > 0:
		reward_string += "\n-" + str(minus_count) + " Speed"
	if plus_count > 0:
		reward_string += "\n+" + str(plus_count) + " Speed"
		
	# remove initial line break
	return reward_string.erase(0)

# Rotates array 90 degrees clockwise, assuming that array is a full rectangle (all rows same size)
func rotate_array(arr) -> Array[Array]:
	var new_arr:Array[Array] = []
	for i in range(len(arr[0])):
		var row = []
		for j in range(len(arr)):
			row.append(arr[len(arr) - j - 1][i])
		new_arr.append(row)
	return new_arr
