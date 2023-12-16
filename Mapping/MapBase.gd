class_name MapBase extends Node

#Empty, Train, Mountain, Rail, Water, Locomotive, Goal
enum {E, T, M, R, W, L, G}
var DIR = Global.DIR

var tiles:Array[TileOptions]
var shape:Vector2i
var startTile:Vector2i
var speedProgression:Array[int]
