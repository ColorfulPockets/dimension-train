extends Tile



func _init():
	cells = [
		[E, E, E, E, E, E, E, E, E, E, E, E, E, E, E],
		[E, E, E, E, E, E, E, E, E, E, E, E, E, E, E],
		[E, E, E, E, E, E, E, E, E, E, E, E, E, E, E],
		[E, E, E, E, E, E, E, E, E, E, E, E, E, E, E],
		[E, E, E, E, E, E, E, E, E, E, E, E, E, E, E],
		[E, E, E, E, E, E, E, E, E, E, E, E, E, E, E],
		[E, E, E, E, E, E, E, E, E, E, E, E, E, E, E],
		[L, E, E, E, E, E, E, E, E, E, E, E, E, E, 1],
		[E, E, E, E, E, E, E, E, E, E, E, E, E, E, E],
		[E, E, E, E, E, E, E, E, E, E, E, E, E, E, E],
		[E, E, E, E, E, E, E, E, E, E, E, E, E, E, E],
		[E, E, E, E, E, E, E, E, E, E, E, E, E, E, E],
		[E, E, E, E, E, E, E, E, E, E, E, E, E, E, E],
		[E, E, E, E, E, E, E, E, E, E, E, E, E, E, E],
		[E, E, E, E, E, E, E, E, E, E, E, E, E, E, E]]
	
	cell_info = {
		1: goalWithRewards(6),
	}
	
	
