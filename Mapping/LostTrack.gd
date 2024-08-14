class_name LostTrack extends Tile



func _init():
	cells = [
		[X, X, X, X, X, 3, 4, X, X, X, X, X, X, X, X],
		[X, X, X, X, 5, 6, X, X, X, X, X, X, X, X, X],
		[X, X, X, 7, 8, X, X, X, X, X, X, X, X, X, X],
		[X, X, X, X, X, X, X, X, X, X, X, X, X, X, X],
		[X, X, X, X, X, X, X, X, X, X, X, X, X, X, X],
		[E, X, X, X, X, X, X, X, X, X, W, X, X, X, 1],
		[E, E, X, X, X, X, X, X, W, W, W, W, W, W, E],
		[L, E, E, E, E, E, W, W, W, W, W, W, W, W, W],
		[E, E, X, X, X, X, X, X, W, W, W, W, W, W, E],
		[E, X, X, X, X, X, 9, 10, X, X, W, X, X, X, X],
		[X, X, X, 11, 12, X, X, X, X, X, X, X, X, X, X],
		[X, X, X, X, X, X, X, X, X, X, X, X, X, X, X],
		[X, X, X, X, 13, 14, X, X, X, X, X, X, X, X, X],
		[X, X, X, X, X, X, X, X, X, X, X, X, X, X, 2],
		[X, X, X, X, X, X, X, X, X, X, X, X, X, X, X]]
	
	cell_info = {
		1: goalWithRewards(12),
		2: goalWithRewards(12),
		
		3: railWithDirections([DIR.D, DIR.R]),
		4: railWithDirections([DIR.L, DIR.R]),
		5: railWithDirections([DIR.D, DIR.R]),
		6: railWithDirections([DIR.L, DIR.U]),
		7: railWithDirections([DIR.L, DIR.R]),
		8: railWithDirections([DIR.L, DIR.U]),
		
		9: railWithDirections([DIR.L, DIR.R]),
		10: railWithDirections([DIR.L, DIR.R]),
		11: railWithDirections([DIR.L, DIR.R]),
		12: railWithDirections([DIR.L, DIR.R]),
		13: railWithDirections([DIR.L, DIR.R]),
		14: railWithDirections([DIR.L, DIR.R]),
	}
	
