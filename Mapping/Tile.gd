class_name Tile extends Node

var cells:Array[Array]
var directions:Array[Array]

func _init(cells:Array[Array], directions:Array[Array]):
	self.cells = cells
	self.directions = directions
