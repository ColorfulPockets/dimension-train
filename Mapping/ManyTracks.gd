class_name ManyTracks extends Tile

func _init():
	cells = [
		[E, X, X, X, X, X, X, X, X, X],
		[E, X, X, X, X, X, X, X, X, X],
		[E, X, X, X, X, X, X, X, X, X],
		[E, X, X, X, X, X, X, X, X, X],
		[E, X, X, X, X, X, X, X, X, X],
		[E, X, X, X, X, X, X, X, X, X],
		[E, X, X, X, X, X, X, X, X, X],
		[E, X, X, X, X, X, X, X, X, X],
		[R, E, E, E, E, E, E, E, E, E],
		[R, R, R, R, R, R, R, E, L, E],
		]
	directions = [
		[E, X, X, X, X, X, X, X, X, X],
		[E, X, X, X, X, X, X, X, X, X],
		[E, X, X, X, X, X, X, X, X, X],
		[E, X, X, X, X, X, X, X, X, X],
		[E, X, X, X, X, X, X, X, X, X],
		[E, X, X, X, X, X, X, X, X, X],
		[E, X, X, X, X, X, X, X, X, X],
		[E, X, X, X, X, X, X, X, X, X],
		[[DIR.D, DIR.U], E, E, E, E, E, E, E, E, E],
		[[DIR.R, DIR.U], [DIR.R, DIR.L], [DIR.R, DIR.L], [DIR.R, DIR.L], [DIR.R, DIR.L], [DIR.R, DIR.L], [DIR.R, DIR.L], E, [DIR.D, DIR.U], E],]
