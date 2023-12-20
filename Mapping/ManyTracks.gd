class_name ManyTracks extends MapBase

var BL = Tile.new([
	[E, X, X, X, X, X, X, X, X, X],
	[E, X, X, X, X, X, X, X, X, X],
	[E, X, X, X, X, X, X, X, X, X],
	[E, X, X, X, X, X, X, X, X, X],
	[E, X, X, X, X, X, X, X, X, X],
	[E, X, X, X, X, X, X, X, X, X],
	[E, X, X, X, X, X, X, X, X, X],
	[E, X, X, X, X, X, X, X, X, X],
	[R, E, E, E, E, E, E, E, E, E],
	[R, R, R, R, R, R, R, E, L, E],
	],
	[
	[E, X, X, X, X, X, X, X, X, X],
	[E, X, X, X, X, X, X, X, X, X],
	[E, X, X, X, X, X, X, X, X, X],
	[E, X, X, X, X, X, X, X, X, X],
	[E, X, X, X, X, X, X, X, X, X],
	[E, X, X, X, X, X, X, X, X, X],
	[E, X, X, X, X, X, X, X, X, X],
	[E, X, X, X, X, X, X, X, X, X],
	[[DIR.D, DIR.U], E, E, E, E, E, E, E, E, E],
	[[DIR.R, DIR.U], [DIR.R, DIR.L], [DIR.R, DIR.L], [DIR.R, DIR.L], [DIR.R, DIR.L], [DIR.R, DIR.L], [DIR.R, DIR.L], E, [DIR.D, DIR.U], E],])
	

var TLBR = Tile.new([
	[E, X, E, X, X, X, X, E, X, E],
	[X, E, X, E, X, X, E, X, E, X],
	[E, X, E, X, X, X, X, E, X, E],
	[X, E, X, W, X, R, E, X, E, X],
	[E, X, E, W, R, R, X, E, X, E],
	[X, E, X, W, R, X, E, X, E, X],
	[E, X, E, W, W, W, W, E, X, E],
	[X, E, X, E, X, X, E, X, E, X],
	[E, X, E, X, X, X, X, E, X, E],
	[X, E, X, E, X, X, E, X, E, X],
], [
	[E, X, E, X, X, X, X, E, X, E],
	[X, E, X, E, X, X, E, X, E, X],
	[E, X, E, X, X, X, X, E, X, E],
	[X, E, X, E, X, [DIR.D, DIR.U], E, X, E, X],
	[E, X, E, W, [DIR.D, DIR.R], [DIR.L, DIR.U], X, E, X, E],
	[X, E, X, W, [DIR.D, DIR.U], X, E, X, E, X],
	[E, X, E, W, W, W, X, E, X, E],
	[X, E, X, E, X, X, E, X, E, X],
	[E, X, E, X, X, X, X, E, X, E],
	[X, E, X, E, X, X, E, X, E, X],
	])

var TR = Tile.new([
	[X, X, X, X, X, X, X, X, X, G],
	[X, X, X, X, X, X, X, X, X, X],
	[X, X, X, X, X, X, X, X, X, X],
	[X, X, X, X, X, X, X, X, X, X],
	[X, X, X, X, X, X, X, X, X, X],
	[X, X, X, X, X, X, X, X, X, X],
	[X, X, X, X, X, X, X, X, X, X],
	[X, X, X, X, X, X, X, X, X, X],
	[X, X, X, X, X, X, X, X, X, X],
	[X, X, X, X, X, X, X, X, X, X],
	],
	[
	[X, X, X, X, X, X, X, X, X, [DIR.D, DIR.U]],
	[X, X, X, X, X, X, X, X, X, X],
	[X, X, X, X, X, X, X, X, X, X],
	[X, X, X, X, X, X, X, X, X, X],
	[X, X, X, X, X, X, X, X, X, X],
	[X, X, X, X, X, X, X, X, X, X],
	[X, X, X, X, X, X, X, X, X, X],
	[X, X, X, X, X, X, X, X, X, X],
	[X, X, X, X, X, X, X, X, X, X],
	[X, X, X, X, X, X, X, X, X, X],
		])

func _init():
	var bottomLeft: Array[Tile] = [BL]
	var tlbr: Array[Tile] = [TLBR]
	var tr: Array[Tile] = [TR]
	shape = Vector2i(2,2)
	tiles = [
		TileOptions.new(tlbr),
		TileOptions.new(bottomLeft),
		TileOptions.new(tr),
		TileOptions.new(tlbr),
	]
	startTile = Vector2i(0,1)
	speedProgression = [0, 0, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4]
	
