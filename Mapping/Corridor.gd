class_name Corridor extends MapBase

var StarterTile1 = Tile.new([
	[T, T, T, T, E, E, W, M, M, M],
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
	[T, T, T, T, E, E, W, M, M, M],
	[T, T, T, T, E, W, W, M, M, M],
	[T, T, T, W, E, E, W, M, M, M],
	[T, T, T, W, W, E, M, M, M, M],
	[T, T, T, W, E, E, W, M, M, M],
	[T, T, T, T, E, W, W, M, M, M],
	[T, T, T, T, E, E, W, M, M, M],
	[E, E, E, E, W, E, E, E, E, E],
	[E, E, E, E, E, E, E, E, E, E],
	[E, E, E, E, E, E, E, L, E, E]])

func _init():
	var starterTileArray: Array[Tile] = [StarterTile1, StarterTile2]
	shape = Vector2i(1,1)
	tiles = [
		TileOptions.new(starterTileArray)
	]
	
