class_name Tile extends Node

#Empty, Tree, Mountain, Water, Locomotive, Random between [Mountain, Tree, Empty], Space
# This used to be an enum, but I wanted the positive integers for cell_info keys
const E = -1
const T = -2
const M = -3
const W = -4
const L = -5
const X = -6
const S = -7
enum TYPES {Goal, Rail, Spawner}
enum {Directions, Type, Rewards, SpawnerName, SpawnerCount}
enum {Cells, CellInfo, SpeedRamp}
enum REWARDS {Easy, Hard, WaterCheck}

static var DIR = Global.DIR

##### Speed Ramp Functions #####
static var equalsTurn:Callable = func(turnNumber): return turnNumber
static var slowBuild:Callable = func(turnNumber): return turnNumber - (turnNumber % 2)
static var turnPlusOne:Callable = func(turnNumber): return turnNumber + 1

static var mapDb = {
	"Corridor": {
		Cells: [
			[S, S, S, T, T, T, T, T, T, T, T, T, S, S, S],
			[S, S, E, T, T, T, T, T, T, T, T, T, T, S, S],
			[S, E, E, T, T, W, W, W, T, T, T, T, T, T, S],
			[E, E, E, E, E, E, W, E, E, E, E, E, E, E, 0],
			[E, E, W, E, W, E, E, E, W, E, E, E, E, E, E],
			[E, E, E, W, W, W, M, W, W, M, M, M, M, M, M],
			[E, E, E, M, M, M, M, M, M, M, M, M, M, M, M],
			[L, E, E, M, M, 2, M, M, M, M, M, M, M, M, M],
			[E, E, E, M, M, M, M, M, M, M, M, M, M, M, M],
			[E, E, E, W, W, W, M, W, W, M, M, M, M, M, M],
			[E, E, W, E, W, E, E, E, W, E, E, E, E, E, E],
			[E, E, E, E, E, E, W, E, E, E, E, E, E, E, 1],
			[S, E, E, T, T, W, W, W, T, T, T, T, T, T, S],
			[S, S, E, T, T, T, T, T, T, T, T, T, T, S, S],
			[S, S, S, T, T, T, T, T, T, T, T, T, S, S, S]],
	
		CellInfo: {
			0: goalWithRewards(REWARDS.Easy),
			1: goalWithRewards(REWARDS.Easy),
			2: spawnerWithName("Guard Factory", 1)
		},
		
		SpeedRamp: equalsTurn
	},
	"Diverging": {
		Cells: [
			[X, X, X, X, X, X, X, X, X, X, X, X, X, X, 0], #15
			[X, X, X, X, X, X, X, X, X, X, X, X, X, X, X],
			[X, X, X, X, X, X, X, X, X, X, X, X, X, X, X],
			[X, 7, X, X, X, X, X, X, X, X, X, X, X, X, X],
			[X, X, X, X, X, X, X, X, X, X, X, X, X, X, X],
			[E, E, W, W, W, W, W, W, W, W, W, W, W, W, W],
			[E, E, W, W, W, W, W, W, W, W, W, W, W, W, W],
			[L, E, W, W, W, W, W, W, W, W, W, W, W, W, W],
			[E, E, W, W, W, W, W, W, W, W, W, W, W, W, 1], #20
			[E, E, W, W, W, W, W, W, W, W, W, W, W, W, W],
			[E, E, W, W, W, W, W, W, W, W, W, W, W, W, W],
			[E, E, W, W, W, W, W, W, W, W, W, W, W, W, W],
			[E, E, T, T, T, T, T, T, T, T, T, T, T, T, T], 
			[E, E, E, E, E, 4, 5, 6, E, E, E, E, E, E, 2], #6
			[E, E, M, M, M, M, M, M, M, M, M, M, M, M, M]],

		CellInfo: {
			0: goalWithRewards(REWARDS.Hard),
			1: goalWithRewards(REWARDS.WaterCheck),
			2: goalWithRewards(REWARDS.Easy),
			
			4: railWithDirections([DIR.L, DIR.R]),
			5: railWithDirections([DIR.L, DIR.R]),
			6: railWithDirections([DIR.L, DIR.R]),
			
			7: spawnerWithName("Guard Factory", 1)
		},
		SpeedRamp: turnPlusOne
			
	},
	"LostTrack": {
		Cells: [
			[X, X, X, X, X, 3, 4, X, X, X, X, X, X, X, X],
			[X, X, X, X, 5, 6, X, X, X, X, X, X, X, X, X],
			[X, X, X, 7, 8, X, X, X, X, X, X, X, X, X, X],
			[X, X, X, X, X, X, X, 15, X, X, X, X, X, X, X],
			[X, X, X, X, X, X, X, X, X, X, X, X, X, X, X],
			[E, X, X, X, X, X, X, X, X, X, W, X, X, X, 0], # 14
			[E, E, X, X, X, X, X, X, W, W, W, W, W, W, E],
			[L, E, E, E, E, E, W, W, W, W, W, W, W, W, W],
			[E, E, X, X, X, X, X, X, W, W, W, W, W, W, E],
			[E, X, X, X, X, X, 9, 10, X, X, W, X, X, X, X],
			[X, X, X, 11, 12, X, X, X, X, X, X, X, X, X, X],
			[X, X, X, 16, X, X, X, X, X, X, X, X, X, X, X],
			[X, X, X, X, 13, 14, X, X, X, X, X, X, X, X, X],
			[X, X, X, X, X, X, X, X, X, X, X, X, X, X, 1], # 12
			[X, X, X, X, X, X, X, X, X, X, X, X, X, X, X]],
		
		CellInfo: {
			0: goalWithRewards(REWARDS.Easy),
			1: goalWithRewards(REWARDS.Easy),
			
			3: railWithDirections([DIR.D, DIR.R]),
			4: railWithDirections([DIR.L, DIR.R]),
			5: railWithDirections([DIR.D, DIR.R]),
			6: railWithDirections([DIR.L, DIR.U]),
			7: railWithDirections([DIR.L, DIR.R]),
			8: railWithDirections([DIR.L, DIR.U]),
			
			9: railWithDirections([DIR.L, DIR.R]),
			10: railWithDirections([DIR.L, DIR.R]),
			11: railWithDirections([DIR.L, DIR.R]),
			12: railWithDirections([DIR.L, DIR.R]),
			13: railWithDirections([DIR.L, DIR.R]),
			14: railWithDirections([DIR.L, DIR.R]),

			15: spawnerWithName("Guard Factory", 1),
			16: spawnerWithName("Guard Factory", 1),
		},
		
		SpeedRamp: slowBuild
	},
	"SlugForest": {
		Cells: [
			[M, M, M, M, M, M, M, M, M, M, M, M, M, M, M],
			[X, M, M, M, M, M, M, M, M, M, M, M, M, M, X],
			[X, X, M, M, M, M, M, M, M, M, M, M, M, X, 0], # 17
			[X, X, X, M, M, M, M, M, M, M, M, M, X, X, X],
			[X, X, X, X, M, M, M, W, M, M, M, X, X, X, X],
			[X, X, X, X, X, X, W, W, W, X, X, X, X, 3, X],
			[X, X, X, X, X, W, W, T, W, W, E, E, E, 4, E],
			[L, E, E, E, W, W, T, 13, T, W, W, E, E, 5, E],
			[E, E, E, E, E, W, W, T, W, W, E, E, E, 6, E],
			[E, E, E, X, X, X, W, W, W, X, X, E, E, 7, E],
			[E, E, X, X, X, X, X, W, X, X, X, X, X, X, X],
			[X, X, T, X, X, X, T, T, X, X, X, X, X, X, X],
			[X, T, T, T, 8, 9, 10, T, X, X, X, X, X, X, X],
			[T, T, T, T, T, T, 11, 12, T, X, X, X, X, X, X],
			[T, T, T, T, T, T, T, T, X, X, X, X, X, X, 1]], # 13

		CellInfo:  {
			0: goalWithRewards(REWARDS.Hard),
			1: goalWithRewards(REWARDS.Easy),
			
			3: railWithDirections([DIR.U, DIR.D]),
			4: railWithDirections([DIR.U, DIR.D]),
			5: railWithDirections([DIR.U, DIR.D]),
			6: railWithDirections([DIR.U, DIR.D]),
			7: railWithDirections([DIR.U, DIR.D]),
			
			8: railWithDirections([DIR.L, DIR.R]),
			9: railWithDirections([DIR.L, DIR.R]),
			10: railWithDirections([DIR.L, DIR.D]),
			11: railWithDirections([DIR.U, DIR.R]),
			12: railWithDirections([DIR.L, DIR.R]),
			
			13: spawnerWithName("Swamp", 2)
		},
		
		SpeedRamp: slowBuild
	},
	"Moon Witch": {
		Cells: [],
		CellInfo: {
			0: goalWithRewards(REWARDS.Hard),
			1: goalWithRewards(REWARDS.Hard),
		}
	},
}

static func getNumExits(mapName):
	var cell_info = mapDb[mapName][CellInfo]
	var count = 0
	for key in cell_info.keys():
		if cell_info[key][Type] == TYPES.Goal:
			count += 1
	
	return count
		
static func mirrorMap(mapName):
	var cells = mapDb[mapName][Cells]
	var cell_info = mapDb[mapName][CellInfo]
	cells.reverse()
	for key in cell_info.keys():
		if Directions in cell_info[key]:
			var new_dirs = []
			for dir in cell_info[key][Directions]:
				new_dirs.append(invert_if_ud(dir))
			
			cell_info[key][Directions] = new_dirs
	
	return [cells, cell_info]

# Takes a direction and returns its inverse, but only if its U or D
static func invert_if_ud(dir:Global.DIR):
	if dir == Global.DIR.U:
		return Global.DIR.D
	elif dir == Global.DIR.D:
		return Global.DIR.U
	else:
		return dir
	
static func goalWithRewards(val:REWARDS) :
	return {
			Type: TYPES.Goal,
			Directions: [DIR.L, DIR.R],
			Rewards: val
		}

static func railWithDirections(dirs:Array[Global.DIR]) :
	return {
		Type: TYPES.Rail,
		Directions: dirs,
	}

static func spawnerWithName(spawnerName: String, spawnerCount: int):
	return {
		Type: TYPES.Spawner,
		SpawnerName: spawnerName,
		SpawnerCount: spawnerCount
	}
