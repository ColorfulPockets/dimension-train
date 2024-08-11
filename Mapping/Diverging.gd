extends Tile



func _init():
	cells = [
		[X, X, X, X, X, X, X, X, X, X, X, X, X, X, G], #15
		[X, X, X, X, X, X, X, X, X, X, X, X, X, X, X],
		[X, X, X, X, X, X, X, X, X, X, X, X, X, X, X],
		[X, X, X, X, X, X, X, X, X, X, X, X, X, X, X],
		[X, X, X, X, X, X, X, X, X, X, X, X, X, X, X],
		[E, E, W, W, W, W, W, W, W, W, W, W, W, W, W],
		[E, E, W, W, W, W, W, W, W, W, W, W, W, W, W],
		[L, E, W, W, W, W, W, W, W, W, W, W, W, W, W],
		[E, E, W, W, W, W, W, W, W, W, W, W, W, W, G], #20
		[E, E, W, W, W, W, W, W, W, W, W, W, W, W, W],
		[E, E, W, W, W, W, W, W, W, W, W, W, W, W, W],
		[E, E, W, W, W, W, W, W, W, W, W, W, W, W, W],
		[E, E, T, T, T, T, T, T, T, T, T, T, T, T, T], 
		[E, E, E, E, E, R, R, R, E, E, E, E, E, E, G], #6
		[E, E, M, M, M, M, M, M, M, M, M, M, M, M, M]]
	
	directions = {
		# Goals
		Vector2i(14,0) : [DIR.L, DIR.R],
		Vector2i(14,8) : [DIR.L, DIR.R],
		Vector2i(14,12) : [DIR.L, DIR.R],
		
		#Bottom rail
		Vector2i(5,13) : [DIR.L, DIR.R],
		Vector2i(6,13) : [DIR.L, DIR.R],
		Vector2i(7,13) : [DIR.L, DIR.R],
		
		
	}
	
	# Count steps to goal, +2 if there is a resource in the way, shortest path * 0.4 gives reward
	rewardValues = {
		Vector2i(14,0) : 15,
		Vector2i(14,8) : 20,
		Vector2i(14,13) : 6,
	}
	
	enemies = [
	]
	
	
