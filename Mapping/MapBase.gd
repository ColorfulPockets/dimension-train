class_name MapBase extends Node

#Empty, Train, Mountain, Rail, Water, Locomotive
enum {E, T, M, R, W, L}

var tiles:Array[TileOptions]
var shape:Vector2i
var speedProgression:Array[int]
