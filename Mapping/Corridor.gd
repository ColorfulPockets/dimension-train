class_name Corridor extends Tile



func _init():
	cells = [
		[T, T, T, T, E, E, M, M, M, M],
		[T, T, T, T, E, W, W, M, M, M],
		[T, T, T, W, E, E, W, M, M, M],
		[T, T, T, W, W, E, M, M, M, M],
		[T, T, T, W, E, E, W, M, M, M],
		[T, T, T, T, E, W, W, M, M, M],
		[T, T, T, T, E, E, W, M, M, M],
		[E, E, E, E, W, E, E, E, E, E],
		[E, E, E, E, E, E, E, E, E, E],
		[E, E, L, E, E, E, E, E, E, E]]
	
	directions = [
		[T, T, T, T, E, E, M, M, M, M],
		[T, T, T, T, E, W, W, M, M, M],
		[T, T, T, W, E, E, W, M, M, M],
		[T, T, T, W, W, E, M, M, M, M],
		[T, T, T, W, E, E, W, M, M, M],
		[T, T, T, T, E, W, W, M, M, M],
		[T, T, T, T, E, E, W, M, M, M],
		[E, E, E, E, W, E, E, E, E, E],
		[E, E, E, E, E, E, E, E, E, E],
		[E, E, L, E, E, E, E, E, E, E]]
	
	
