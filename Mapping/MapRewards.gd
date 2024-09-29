class_name MapRewards extends TextureRect

var mapName:String
var isMirrored:bool
  
# The second value in the sub-arrays tells if there's any special info to render, 
# the third is rewards to add,
# the first is an index so we can tell which path is taken
var rewardsArray:Array

func _init(mapName:String, isMirrored:bool, rewardsArray:Array):
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
