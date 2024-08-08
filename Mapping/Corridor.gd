class_name Corridor extends Tile



func _init():
	cells = Global.rotate_array([
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
		[E, E, E, E, E, E, E, L, E, E, E, E, E, E, E]])
	
	directions = {
		Vector2i(14,3) : [DIR.L, DIR.R],
		Vector2i(14,11) : [DIR.L, DIR.R],
	}
	
		
	rewardValues = {
		Vector2i(14,3) : 8,
		Vector2i(14,11) : 8,
	}
	
	enemies = [
		["Corrupt Slug", Vector2i(5,14), Global.DIR.U]
	]
	
	
