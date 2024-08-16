extends Tile



func _init():
	cells = [
		[M, M, M, M, M, M, M, M, M, M, M, M, M, M, M],
		[X, M, M, M, M, M, M, M, M, M, M, M, M, M, X],
		[X, X, M, M, M, M, M, M, M, M, M, M, M, X, 1], # 17
		[X, X, X, M, M, M, M, M, M, M, M, M, X, X, X],
		[X, X, X, X, M, M, M, W, M, M, M, X, X, X, X],
		[X, X, X, X, X, X, W, W, W, X, X, X, X, 3, X],
		[X, X, X, X, X, W, W, T, W, W, E, E, E, 4, E],
		[L, E, E, E, W, W, T, 13, T, W, W, E, E, 5, E],
		[E, E, E, E, E, W, W, T, W, W, E, E, E, 6, E],
		[E, E, E, X, X, X, W, W, W, X, X, E, E, 7, E],
		[E, E, X, X, X, X, X, W, X, X, X, X, X, X, X],
		[X, X, T, X, X, X, T, T, X, X, X, X, X, X, X],
		[X, T, T, T, 8, 9, 10, T, X, X, X, X, X, X, X],
		[T, T, T, T, T, T, 11, 12, T, X, X, X, X, X, X],
		[T, T, T, T, T, T, T, T, X, X, X, X, X, X, 2]] # 13

	cell_info = {
		1: goalWithRewards(17),
		2: goalWithRewards(13),
		
		3: railWithDirections([DIR.U, DIR.D]),
		4: railWithDirections([DIR.U, DIR.D]),
		5: railWithDirections([DIR.U, DIR.D]),
		6: railWithDirections([DIR.U, DIR.D]),
		7: railWithDirections([DIR.U, DIR.D]),
		
		8: railWithDirections([DIR.L, DIR.R]),
		9: railWithDirections([DIR.L, DIR.R]),
		10: railWithDirections([DIR.L, DIR.D]),
		11: railWithDirections([DIR.U, DIR.R]),
		12: railWithDirections([DIR.L, DIR.R]),
		
		13: spawnerWithName("Swamp", 2)
	}
	
	
	
