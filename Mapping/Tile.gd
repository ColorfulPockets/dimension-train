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
static var DIR = Global.DIR

var cells:Array[Array]

var cell_info: Dictionary
	
func getNumExits():
	var count = 0
	for key in cell_info.keys():
		if cell_info[key][Type] == TYPES.Goal:
			count += 1
	
	return count
		

func mirrorMap():
	cells.reverse()
	for key in cell_info.keys():
		if Directions in cell_info[key]:
			var new_dirs = []
			for dir in cell_info[key][Directions]:
				new_dirs.append(invert_if_ud(dir))
			
			cell_info[key][Directions] = new_dirs

# Takes a direction and returns its inverse, but only if its U or D
func invert_if_ud(dir:Global.DIR):
	if dir == Global.DIR.U:
		return Global.DIR.D
	elif dir == Global.DIR.D:
		return Global.DIR.U
	else:
		return dir
	
static func goalWithRewards(val:int) :
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
