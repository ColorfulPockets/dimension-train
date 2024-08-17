extends Tile



func _init():
	cells = [
		[X, X, X, X, X, X, X, X, X, X, X, X, X, X, 1], #15
		[X, X, X, X, X, X, X, X, X, X, X, X, X, X, X],
		[X, X, X, X, X, X, X, X, X, X, X, X, X, X, X],
		[X, 7, X, X, X, X, X, X, X, X, X, X, X, X, X],
		[X, X, X, X, X, X, X, X, X, X, X, X, X, X, X],
		[E, E, W, W, W, W, W, W, W, W, W, W, W, W, W],
		[E, E, W, W, W, W, W, W, W, W, W, W, W, W, W],
		[L, E, W, W, W, W, W, W, W, W, W, W, W, W, W],
		[E, E, W, W, W, W, W, W, W, W, W, W, W, W, 2], #20
		[E, E, W, W, W, W, W, W, W, W, W, W, W, W, W],
		[E, E, W, W, W, W, W, W, W, W, W, W, W, W, W],
		[E, E, W, W, W, W, W, W, W, W, W, W, W, W, W],
		[E, E, T, T, T, T, T, T, T, T, T, T, T, T, T], 
		[E, E, E, E, E, 4, 5, 6, E, E, E, E, E, E, 3], #6
		[E, E, M, M, M, M, M, M, M, M, M, M, M, M, M]]
	
	cell_info = {
		1: goalWithRewards(15),
		2: goalWithRewards(20),
		3: goalWithRewards(6),
		
		4: railWithDirections([DIR.L, DIR.R]),
		5: railWithDirections([DIR.L, DIR.R]),
		6: railWithDirections([DIR.L, DIR.R]),
		
		7: spawnerWithName("Guard Factory", 1)
	}
	
	
	
