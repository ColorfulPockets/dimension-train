class_name Corridor extends Tile



func _init():
	cells = [
		[T, T, T, G, E, M, M, M, M, M, E, G, T, T, T],
		[T, T, T, E, E, M, M, M, M, M, E, E, T, T, T],
		[T, T, T, E, E, M, M, M, M, M, E, E, T, T, T],
		[T, T, T, E, E, M, M, M, M, M, E, E, T, T, T],
		[T, T, T, E, E, M, M, M, M, M, E, E, T, T, T],
		[T, T, T, E, E, M, M, M, M, M, E, E, T, T, T],
		[T, T, T, E, W, W, M, M, M, W, W, E, T, T, T],
		[T, T, W, E, E, W, M, M, M, W, E, E, W, T, T],
		[T, T, W, W, E, M, M, M, M, M, E, W, W, T, T],
		[T, T, W, E, E, W, M, M, M, W, E, E, W, T, T],
		[T, T, T, E, W, W, M, M, M, W, W, E, T, T, T],
		[T, T, T, E, E, W, M, M, M, W, E, E, T, T, T],
		[E, E, E, E, W, E, E, E, E, E, W, E, E, E, E],
		[E, E, E, E, E, E, E, E, E, E, E, E, E, E, E],
		[E, E, E, E, E, E, E, L, E, E, E, E, E, E, E]]
	
	directions = {
		Vector2i(3,0) : [DIR.D, DIR.U],
		Vector2i(11,0) : [DIR.D, DIR.U],
	}
	
		
	rewardValues = {
		Vector2i(3,0) : 0.25,
		Vector2i(11,0) : 1.0,
	}
	
	
