class_name Tile extends Node

#Empty, Tree, Mountain, Water, Locomotive, Random between [Mountain, Tree, Empty]
# This used to be an enum, but I wanted the positive integers for cell_info keys
const E = -1
const T = -2
const M = -3
const W = -4
const L = -5
const X = -6
enum TYPES {Goal, Rail, Spawner}
enum {Directions, Type, Rewards, SpawnerName}
static var DIR = Global.DIR

var cells:Array[Array]

var cell_info: Dictionary

func _init(cells:Array[Array], cell_info:Dictionary):
	self.cells = cells
	self.cell_info = cell_info
	
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

static func spawnerWithName(spawnerName: String):
	return {
		Type: TYPES.Spawner,
		SpawnerName: spawnerName
	}
