extends Tile



func _init():
	cells = [
		[M, M, M, M, M, M, M, M, M, M, M, M, M, M, M],
		[X, M, M, M, M, M, M, M, M, M, M, M, M, M, X],
		[X, X, M, M, M, M, M, M, M, M, M, M, M, X, G],
		[X, X, X, M, M, M, M, M, M, M, M, M, X, X, X],
		[X, X, X, X, M, M, M, W, M, M, M, X, X, X, X],
		[X, X, X, X, X, X, W, W, W, X, X, X, X, R, X],
		[X, X, X, X, X, W, W, T, W, W, E, E, E, R, E],
		[L, E, E, E, W, W, T, T, T, W, W, E, E, R, E],
		[E, E, E, E, E, W, W, T, W, W, E, E, E, R, E],
		[E, E, E, X, X, X, W, W, W, X, X, E, E, R, E],
		[E, E, X, X, X, X, X, W, X, X, X, X, X, X, X],
		[X, X, T, X, X, X, T, T, X, X, X, X, X, X, X],
		[X, T, T, T, R, R, R, T, X, X, X, X, X, X, X],
		[T, T, T, T, T, T, R, R, T, X, X, X, X, X, X],
		[T, T, T, T, T, T, T, T, X, X, X, X, X, X, G]]

	
	directions = {
		#Endpoints
		Vector2i(14,2) : [DIR.L, DIR.R],
		Vector2i(14,14) : [DIR.L, DIR.R],
		
		#Bottom Rail Group
		Vector2i(4, 12) : [DIR.L, DIR.R],
		Vector2i(5, 12) : [DIR.L, DIR.R],
		Vector2i(6, 12) : [DIR.L, DIR.D],
		Vector2i(6, 13) : [DIR.U, DIR.R],
		Vector2i(7, 13) : [DIR.L, DIR.R],
		
		# Vertical Right Rail Group
		Vector2i(13, 5) : [DIR.U, DIR.D],
		Vector2i(13, 6) : [DIR.U, DIR.D],
		Vector2i(13, 7) : [DIR.U, DIR.D],
		Vector2i(13, 8) : [DIR.U, DIR.D],
		Vector2i(13, 9) : [DIR.U, DIR.D],
		
	}
	
		
	rewardValues = {
		Vector2i(14,2) : 17,
		Vector2i(14,14) : 13,
	}
	
	enemies = [
		["Corrupt Slug", Vector2i(6,6), Global.DIR.U],
		["Corrupt Slug", Vector2i(6,8), Global.DIR.D],
		["Corrupt Slug", Vector2i(8,6), Global.DIR.U],
		["Corrupt Slug", Vector2i(8,8), Global.DIR.D],
	]
	
	
