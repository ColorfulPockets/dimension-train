class_name Corridor extends Tile

func _init():
	cells = Global.rotate_array([
		[T, T, T, 1, E, M, M, M, M, M, E, 2, T, T, T],
		[T, T, T, E, E, M, M, M, M, M, E, E, T, T, T],
		[T, T, T, E, E, M, M, M, M, M, E, E, T, T, T],
		[T, T, T, E, E, M, M, M, M, M, E, E, T, T, T],
		[T, T, T, E, E, M, M, M, M, M, E, E, T, T, T],
		[T, T, T, E, E, M, M, M, M, M, E, E, T, T, T],
		[T, T, T, E, W, W, M, M, M, W, W, E, T, T, T],
		[T, T, W, E, E, W, M, M, M, W, E, E, W, T, T],
		[T, T, W, W, E, M, M, M, M, M, E, W, W, T, T],
		[T, T, W, E, E, W, M, 3, M, W, E, E, W, T, T],
		[T, T, T, E, W, W, M, M, M, W, W, E, T, T, T],
		[T, T, T, E, E, W, M, M, M, W, E, E, T, T, T],
		[E, E, E, E, W, E, E, E, E, E, W, E, E, E, E],
		[E, E, E, E, E, E, E, E, E, E, E, E, E, E, E],
		[E, E, E, E, E, E, E, L, E, E, E, E, E, E, E]])
	
	cell_info = {
		1: goalWithRewards(10),
		2: goalWithRewards(10),
		3: spawnerWithName("Guard Factory", 1)
	}
	
