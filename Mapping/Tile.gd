class_name Tile extends Node

#Empty, Tree, Mountain, Rail, Water, Locomotive, Goal, Random between [Mountain, Tree, Empty]
enum {E, T, M, R, W, L, G, X}
var DIR = Global.DIR

var cells:Array[Array]
var directions:Dictionary
var rewardValues:Dictionary

func _init(cells:Array[Array], directions:Dictionary):
	self.cells = cells
	self.directions = directions
