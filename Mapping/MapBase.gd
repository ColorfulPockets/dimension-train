class_name MapBase extends Node

#Empty, Tree, Mountain, Rail, Water, Locomotive, Goal, Random between [Mountain, Tree, Empty]
enum {E, T, M, R, W, L, G, X}
var DIR = Global.DIR

var tiles:Array[TileOptions]
var shape:Vector2i
var startTile:Vector2i
var speedProgression:Array[int]
