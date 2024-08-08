class_name LostTrack extends Tile



func _init():
	cells = [
		[X, X, X, X, X, R, R, X, X, X, X, X, X, X, X],
		[X, X, X, X, R, R, X, X, X, X, X, X, X, X, X],
		[X, X, X, R, R, X, X, X, X, X, X, X, X, X, X],
		[X, X, X, X, X, X, X, X, X, X, X, X, X, X, X],
		[X, X, X, X, X, X, X, X, X, X, X, X, X, X, X],
		[E, X, X, X, X, X, X, X, X, X, W, X, X, X, G],
		[E, E, X, X, X, X, X, X, W, W, W, W, W, W, E],
		[L, E, E, E, E, E, W, W, W, W, W, W, W, W, W],
		[E, E, X, X, X, X, X, X, W, W, W, W, W, W, E],
		[E, X, X, X, X, X, R, R, X, X, W, X, X, X, X],
		[X, X, X, R, R, X, X, X, X, X, X, X, X, X, X],
		[X, X, X, X, X, X, X, X, X, X, X, X, X, X, X],
		[X, X, X, X, R, R, X, X, X, X, X, X, X, X, X],
		[X, X, X, X, X, X, X, X, X, X, X, X, X, X, G],
		[X, X, X, X, X, X, X, X, X, X, X, X, X, X, X]]
	
	directions = {
		# Top rail group
		Vector2i(5,0) : [DIR.D, DIR.R],
		Vector2i(6,0) : [DIR.L, DIR.R],
		Vector2i(4,1) : [DIR.D, DIR.R],
		Vector2i(5,1) : [DIR.L, DIR.U],
		Vector2i(3,2) : [DIR.L, DIR.R],
		Vector2i(4,2) : [DIR.L, DIR.U],
		
		# Bottom rail groups
		Vector2i(6,9) : [DIR.L, DIR.R],
		Vector2i(7,9) : [DIR.L, DIR.R],
		Vector2i(3,10) : [DIR.L, DIR.R],
		Vector2i(4,10) : [DIR.L, DIR.R],
		Vector2i(4,12) : [DIR.L, DIR.R],
		Vector2i(5,12) : [DIR.L, DIR.R],
		
		#Endpoints
		Vector2i(14,5) : [DIR.L, DIR.R],
		Vector2i(14,13) : [DIR.L, DIR.R],
	}
	
		
	rewardValues = {
		Vector2i(14,5) : 12,
		Vector2i(14,13) : 12,
	}
	
	enemies = [
		["Corrupt Slug", Vector2i(5,14), Global.DIR.U]
	]
	
	
