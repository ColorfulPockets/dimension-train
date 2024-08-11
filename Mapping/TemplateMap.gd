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
		[L, E, E, E, E, E, E, E, E, E, E, E, E, E, G],
		[E, E, E, E, E, E, E, E, E, E, E, E, E, E, E],
		[E, E, E, E, E, E, E, E, E, E, E, E, E, E, E],
		[E, E, E, E, E, E, E, E, E, E, E, E, E, E, E],
		[E, E, E, E, E, E, E, E, E, E, E, E, E, E, E],
		[E, E, E, E, E, E, E, E, E, E, E, E, E, E, E],
		[E, E, E, E, E, E, E, E, E, E, E, E, E, E, E],
		[E, E, E, E, E, E, E, E, E, E, E, E, E, E, E]]
	
	directions = {
		Vector2i(14,7) : [DIR.L, DIR.R],
	}
	
	# Count steps to goal, +2 if there is a resource in the way, shortest path * 0.4 gives reward
	rewardValues = {
		Vector2i(14,7) : 8,
	}
	
	enemies = [
		["Corrupt Slug", Vector2i(7,7), Global.DIR.D],
	]
	
	
