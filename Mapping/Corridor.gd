class_name Corridor extends MapBase

var StarterTile1 = Tile.new([
	[T, T, T, T, E, E, M, M, M, M],
	[T, T, T, T, E, W, W, M, M, M],
	[T, T, T, W, E, E, W, M, M, M],
	[T, T, T, W, W, E, M, M, M, M],
	[T, T, T, W, E, E, W, M, M, M],
	[T, T, T, T, E, W, W, M, M, M],
	[T, T, T, T, E, E, W, M, M, M],
	[E, E, E, E, W, E, E, E, E, E],
	[E, E, E, E, E, E, E, E, E, E],
	[E, E, L, E, E, E, E, E, E, E]],
	[
	[T, T, T, T, E, E, M, M, M, M],
	[T, T, T, T, E, W, W, M, M, M],
	[T, T, T, W, E, E, W, M, M, M],
	[T, T, T, W, W, E, M, M, M, M],
	[T, T, T, W, E, E, W, M, M, M],
	[T, T, T, T, E, W, W, M, M, M],
	[T, T, T, T, E, E, W, M, M, M],
	[E, E, E, E, W, E, E, E, E, E],
	[E, E, E, E, E, E, E, E, E, E],
	[E, E, L, E, E, E, E, E, E, E]])
	
var StarterTile2 = Tile.new([
	[T, T, T, T, E, E, M, M, M, M],
	[T, T, T, T, E, W, W, M, M, M],
	[T, T, T, W, E, E, W, M, M, M],
	[T, T, T, W, W, E, M, M, M, M],
	[T, T, T, W, E, E, W, M, M, M],
	[T, T, T, T, E, W, W, M, M, M],
	[T, T, T, T, E, E, W, M, M, M],
	[E, E, E, E, W, E, E, E, E, E],
	[E, E, E, E, E, E, E, E, E, E],
	[E, E, E, E, E, E, E, L, E, E]],
	[
	[T, T, T, T, E, E, M, M, M, M],
	[T, T, T, T, E, W, W, M, M, M],
	[T, T, T, W, E, E, W, M, M, M],
	[T, T, T, W, W, E, M, M, M, M],
	[T, T, T, W, E, E, W, M, M, M],
	[T, T, T, T, E, W, W, M, M, M],
	[T, T, T, T, E, E, W, M, M, M],
	[E, E, E, E, W, E, E, E, E, E],
	[E, E, E, E, E, E, E, E, E, E],
	[E, E, E, E, E, E, E, L, E, E]])

var EndTile1 = Tile.new([
	[E, E, E, E, E, E, E, E, E, E],
	[E, E, E, E, E, E, E, E, E, E],
	[E, E, E, E, E, E, E, E, E, E],
	[E, E, E, E, E, E, E, E, E, E],
	[E, T, T, T, E, E, M, M, M, E],
	[E, T, T, T, E, E, M, M, M, E],
	[E, T, T, T, E, E, M, M, M, E],
	[E, T, W, W, G, G, W, W, M, E],
	[E, T, T, W, W, W, W, M, M, E],
	[E, E, T, T, W, W, M, M, E, E]],
	[
	[E, E, E, E, E, E, E, E, E, E],
	[E, E, E, E, E, E, E, E, E, E],
	[E, E, E, E, E, E, E, E, E, E],
	[E, E, E, E, E, E, E, E, E, E],
	[E, T, T, T, E, E, M, M, M, E],
	[E, T, T, T, E, E, M, M, M, E],
	[E, T, T, T, E, E, M, M, M, E],
	[E, T, W, W, [DIR.U, DIR.D], [DIR.U, DIR.D], W, W, M, E],
	[E, T, T, W, W, W, W, M, M, E],
	[E, E, T, T, W, W, M, M, E, E]]
	)
	
var EndTile2 = Tile.new([
	[E, E, E, E, E, E, E, E, E, E],
	[E, E, E, E, E, E, E, E, E, E],
	[E, E, E, E, E, E, E, E, E, E],
	[E, E, E, E, E, E, E, E, E, E],
	[E, E, E, W, G, G, W, E, E, E],
	[E, E, E, W, E, E, W, E, E, E],
	[E, M, M, M, M, M, M, M, M, E],
	[E, M, M, M, M, M, M, M, M, E],
	[E, T, T, T, T, T, T, T, T, E],
	[E, T, T, T, T, T, T, T, T, E]],
	
	[[E, E, E, E, E, E, E, E, E, E],
	[E, E, E, E, E, E, E, E, E, E],
	[E, E, E, E, E, E, E, E, E, E],
	[E, E, E, E, E, E, E, E, E, E],
	[E, E, E, W, [DIR.U, DIR.D], [DIR.U, DIR.D], W, E, E, E],
	[E, E, E, W, E, E, W, E, E, E],
	[E, M, M, M, M, M, M, M, M, E],
	[E, M, M, M, M, M, M, M, M, E],
	[E, T, T, T, T, T, T, T, T, E],
	[E, T, T, T, T, T, T, T, T, E]]
	)

func _init():
	var starterTileArray: Array[Tile] = [StarterTile1, StarterTile2]
	var endTileArray: Array[Tile] = [EndTile1, EndTile2]
	shape = Vector2i(1,2)
	tiles = [
		TileOptions.new(endTileArray),
		TileOptions.new(starterTileArray),
	]
	startTile = Vector2i(0,1)
	speedProgression = [0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10]
	
