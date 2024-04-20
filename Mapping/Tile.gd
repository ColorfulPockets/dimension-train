class_name Tile extends Node

#Empty, Tree, Mountain, Rail, Water, Locomotive, Goal, Random between [Mountain, Tree, Empty]
enum {E, T, M, R, W, L, G, X}
var DIR = Global.DIR

var cells:Array[Array]
var directions:Array[Array]

func _init(cells:Array[Array], directions:Array[Array]):
	self.cells = cells
	self.directions = directions
