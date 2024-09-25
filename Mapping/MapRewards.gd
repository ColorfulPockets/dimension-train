class_name MapRewards extends TextureRect

var mapName
var isMirrored
  
# The first value in the sub-arrays tells if there's any special info to render, 
# the second is rewards to add,
# the third is an index so we can tell which path is taken
var rewardsArray

func _init(mapName, isMirrored, rewardsArray):
	self.mapName = mapName
	self.isMirrored = isMirrored
	self.rewardsArray = rewardsArray
	
	var iconName
	if mapName in Overworld.BASIC_AREAS:
		iconName = "Plains"
	elif mapName in Overworld.MINIBOSSES:
		iconName = "Forest"
	else:
		iconName = mapName
	
	self.texture = load("res://Assets/Icons/" + iconName + ".png")
	self.expand_mode = TextureRect.EXPAND_KEEP_SIZE
	self.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	self.custom_minimum_size = Vector2(50,50)
